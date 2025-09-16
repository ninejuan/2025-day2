#!/bin/bash

set -e

echo "🔧 Running post-apply fixes..."

DEV_VPC_ID=$(terraform output -raw dev_vpc_id)
PROD_VPC_ID=$(terraform output -raw prod_vpc_id)

echo "📋 VPC IDs:"
echo "  Dev VPC: $DEV_VPC_ID"
echo "  Prod VPC: $PROD_VPC_ID"

echo "⏳ Waiting for ALB Controller to be ready..."
echo "🔧 Fixing dev cluster ALB Controller..."
aws eks update-kubeconfig --region eu-central-1 --name dev-cluster

kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system || true

kubectl patch deployment aws-load-balancer-controller -n kube-system -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"aws-load-balancer-controller\",\"args\":[\"--cluster-name=dev-cluster\",\"--ingress-class=alb\",\"--aws-region=eu-central-1\",\"--aws-vpc-id=$DEV_VPC_ID\"]}]}}}}"

echo "✅ Dev ALB Controller patched"

echo "🔧 Fixing prod cluster ALB Controller..."
aws eks update-kubeconfig --region eu-central-1 --name prod-cluster

kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system || true

kubectl patch deployment aws-load-balancer-controller -n kube-system -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"aws-load-balancer-controller\",\"args\":[\"--cluster-name=prod-cluster\",\"--ingress-class=alb\",\"--aws-region=eu-central-1\",\"--aws-vpc-id=$PROD_VPC_ID\"]}]}}}}"

echo "✅ Prod ALB Controller patched"

echo "⏳ Waiting for ALB Controller to be healthy..."
sleep 30

echo "📊 Checking ALB Controller status..."
aws eks update-kubeconfig --region eu-central-1 --name dev-cluster
kubectl get pods -n kube-system | grep aws-load-balancer

aws eks update-kubeconfig --region eu-central-1 --name prod-cluster
kubectl get pods -n kube-system | grep aws-load-balancer

echo "🔧 Changing services to LoadBalancer..."

aws eks update-kubeconfig --region eu-central-1 --name dev-cluster
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"LoadBalancer"}}' || true
kubectl patch svc argo-rollouts-dashboard -n argo-rollouts -p '{"spec":{"type":"LoadBalancer"}}' || true

# aws eks update-kubeconfig --region eu-central-1 --name prod-cluster
# kubectl patch svc argo-rollouts-dashboard -n argo-rollouts -p '{"spec":{"type":"LoadBalancer"}}' || true

echo "✅ Services changed to LoadBalancer"

# echo "📊 Final status check..."
# aws eks update-kubeconfig --region eu-central-1 --name dev-cluster
# echo "Dev cluster services:"
# kubectl get svc -A | grep -E "(argocd|argo-rollouts|LoadBalancer)"

# aws eks update-kubeconfig --region eu-central-1 --name prod-cluster
# echo "Prod cluster services:"
# kubectl get svc -A | grep -E "(argocd|argo-rollouts|LoadBalancer)"

echo "🎉 Post-apply fixes completed successfully!"