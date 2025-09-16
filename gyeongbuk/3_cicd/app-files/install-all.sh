#!/bin/bash
set -euo pipefail

### --------------------------------------------------------------------------------
### 해당 스크립트를 실행하기 전, 아래 체크리스트를 모두 완료하기 바랍니다.
### 1. argocd prod application의 destination server를 prod-cluster의 주소로 변경해주세요.
### --------------------------------------------------------------------------------

# This script installs cluster add-ons and resources without Terraform Helm:
# - Helm repos
# - DEV cluster setup
# - PROD cluster setup
# - Namespaces
# - AWS Load Balancer Controller (pre-req: IRSA service account exists via Terraform)
# - ArgoCD (dev only) and Argo Rollouts (dev/prod)
# - Actions Runner Controller (dev/prod)
# - ArgoCD Applications (dev in-cluster, prod external)
# - ARC RunnerDeployments (dev/prod)

REGION=${AWS_REGION:-eu-central-1}
DEV_CLUSTER=${DEV_CLUSTER_NAME:-dev-cluster}
PROD_CLUSTER=${PROD_CLUSTER_NAME:-prod-cluster}

ROOT_DIR=$(pwd)

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "[ERROR] '$1' required"; exit 1; }
}

require aws
require kubectl
require helm

switch_cluster() {
  local CLUSTER_NAME=$1
  echo "[INFO] Switching to cluster: ${CLUSTER_NAME}"
  aws eks update-kubeconfig --region "${REGION}" --name "${CLUSTER_NAME}" >/dev/null
}

ensure_ns() {
  local NS=$1
  kubectl get ns "$NS" >/dev/null 2>&1 || kubectl create ns "$NS"
}

install_alb_controller() {
  local CLUSTER_NAME=$1
  local VPC_ID=$2

  echo "[INFO] Installing AWS Load Balancer Controller on ${CLUSTER_NAME} (vpc=${VPC_ID})"

  ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

  eksctl create iamserviceaccount \
  --cluster ${CLUSTER_NAME} \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

  echo "Installing CRDs for AWS Load Balancer Controller..."
  kubectl apply -f ${ROOT_DIR}/alb-controller/crds.yaml

  echo "Adding EKS Helm repository..."
  helm repo add eks https://aws.github.io/eks-charts
  helm repo update

  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName="${CLUSTER_NAME}" \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region="${REGION}" \
    $( [[ -n "${VPC_ID}" && "${VPC_ID}" != "-" ]] && echo "--set vpcId=${VPC_ID}" ) \
    --version 1.6.2
}

install_argocd_dev() {
  echo "[INFO] Installing ArgoCD on dev"
  ensure_ns argocd
  helm upgrade --install argocd argo/argo-cd \
    -n argocd \
    --set crds.install=true \
    --set server.service.type=ClusterIP \
    --set server.extraArgs={"--insecure"} \
    --version 5.46.8
  
  echo "[INFO] Waiting for ArgoCD to be ready..."
  kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
  
  echo "[INFO] Registering prod cluster with ArgoCD"
  register_prod_cluster_with_argocd
}

register_prod_cluster_with_argocd() {
  local PROD_ENDPOINT
  PROD_ENDPOINT=$(aws eks describe-cluster --name "${PROD_CLUSTER}" --region "${REGION}" --query 'cluster.endpoint' --output text)
  
  local PROD_CA
  PROD_CA=$(aws eks describe-cluster --name "${PROD_CLUSTER}" --region "${REGION}" --query 'cluster.certificateAuthority.data' --output text)
  
  kubectl create secret generic prod-cluster-secret \
    --from-literal=name="${PROD_CLUSTER}" \
    --from-literal=server="${PROD_ENDPOINT}" \
    --from-literal=config="{\"tlsClientConfig\":{\"insecure\":false,\"caData\":\"${PROD_CA}\"}}" \
    -n argocd \
    --dry-run=client -o yaml | kubectl apply -f -
  
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: prod-cluster-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: ${PROD_CLUSTER}
  server: ${PROD_ENDPOINT}
  config: |
    {
      "tlsClientConfig": {
        "insecure": false,
        "caData": "${PROD_CA}"
      }
    }
EOF
  
  echo "[INFO] Prod cluster registered with ArgoCD"
}

install_rollouts() {
  local TARGET=$1
  echo "[INFO] Installing Argo Rollouts on ${TARGET}"
  ensure_ns argo-rollouts
  helm upgrade --install argo-rollouts argo/argo-rollouts \
    -n argo-rollouts \
    --set installCRDs=true \
    --version 2.32.0
}

install_cert_manager() {
  local TARGET=$1
  echo "[INFO] Installing cert-manager on ${TARGET}"
  ensure_ns cert-manager
  helm upgrade --install cert-manager jetstack/cert-manager \
    -n cert-manager \
    --set installCRDs=true \
    --version v1.13.2
}

install_arc() {
  local TARGET=$1
  echo "[INFO] Installing Actions Runner Controller on ${TARGET}"
  ensure_ns actions-runner-system
  if kubectl get secret controller-manager -n actions-runner-system >/dev/null 2>&1; then
    echo "[INFO] controller-manager secret already exists"
  else
    kubectl apply -f "${ROOT_DIR}/arc/controller-manager-secret.yaml"
  fi
  helm upgrade --install actions-runner-controller actions-runner-controller/actions-runner-controller \
    -n actions-runner-system \
    --set authSecret.create=false \
    --set authSecret.name=controller-manager \
    --set authSecret.key=github_token \
    --version 0.23.3
}

apply_argocd_apps() {
  echo "[INFO] Applying ArgoCD Applications (dev/prod)"
  kubectl apply -f "${ROOT_DIR}/argocd/dev-application.yaml"
  kubectl apply -f "${ROOT_DIR}/argocd/prod-application.yaml"
}

apply_runners() {
  local TARGET=$1
  local TARGET_FILE="${TARGET}-runner-pod.yaml"
  echo "[INFO] Applying ARC RunnerDeployments (${TARGET}) to namespace app"
  ensure_ns app
  kubectl apply -f "${ROOT_DIR}/actions-runner-deployment/${TARGET_FILE}"
}

helm repo add eks https://aws.github.io/eks-charts >/dev/null 2>&1 || true
helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1 || true
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller >/dev/null 2>&1 || true
helm repo add jetstack https://charts.jetstack.io >/dev/null 2>&1 || true
helm repo update >/dev/null

resolve_vpc_id() {
  local CLUSTER_NAME=$1
  local SG_ID
  SG_ID=$(aws eks describe-cluster --name "${CLUSTER_NAME}" --region "${REGION}" --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text 2>/dev/null || echo "-")
  if [[ -z "${SG_ID}" || "${SG_ID}" == "-" ]]; then echo "-"; return; fi
  aws ec2 describe-security-groups --group-ids "${SG_ID}" --region "${REGION}" --query 'SecurityGroups[0].VpcId' --output text 2>/dev/null || echo "-"
}

switch_cluster "${DEV_CLUSTER}"
ensure_ns app
DEV_VPC_AUTO=${DEV_VPC_ID:-}
if [[ -z "${DEV_VPC_AUTO}" ]]; then DEV_VPC_AUTO=$(resolve_vpc_id "${DEV_CLUSTER}"); fi
install_alb_controller "${DEV_CLUSTER}" "${DEV_VPC_AUTO}"
install_argocd_dev
install_rollouts dev
install_cert_manager dev
install_arc dev
apply_runners dev
apply_argocd_apps

switch_cluster "${PROD_CLUSTER}"
ensure_ns app
PROD_VPC_AUTO=${PROD_VPC_ID:-}
if [[ -z "${PROD_VPC_AUTO}" ]]; then PROD_VPC_AUTO=$(resolve_vpc_id "${PROD_CLUSTER}"); fi
install_alb_controller "${PROD_CLUSTER}" "${PROD_VPC_AUTO}"
install_rollouts prod
install_cert_manager prod
install_arc prod
apply_runners prod

echo "[DONE] Add-on installation completed for dev and prod."
