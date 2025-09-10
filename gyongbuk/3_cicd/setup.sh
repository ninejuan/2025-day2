#!/bin/bash

set -e

echo "=== EKS CI/CD Setup Script ==="

if [ -z "$1" ]; then
    echo "Usage: $0 <github-org>"
    echo "Example: $0 your-github-org"
    exit 1
fi

GITHUB_ORG=$1
AWS_REGION="eu-central-1"

echo "Setting up infrastructure..."

terraform init

terraform plan \
    -var="github_org=$GITHUB_ORG" \
    -var="aws_region=$AWS_REGION"

echo "Review the plan above. Press Enter to continue with apply, or Ctrl+C to cancel."
read

terraform apply \
    -var="github_org=$GITHUB_ORG" \
    -var="aws_region=$AWS_REGION" \
    -auto-approve

echo "=== Getting outputs ==="
DEV_CLUSTER_NAME=$(terraform output -raw dev_cluster_name)
PROD_CLUSTER_NAME=$(terraform output -raw prod_cluster_name)
ECR_DEV_URL=$(terraform output -raw dev_ecr_repository_url)
ECR_PROD_URL=$(terraform output -raw prod_ecr_repository_url)
GITHUB_ROLE_ARN=$(terraform output -raw github_actions_role_arn)
BASTION_IP=$(terraform output -raw bastion_public_ip)

echo "=== Infrastructure created successfully ==="
echo "Dev Cluster: $DEV_CLUSTER_NAME"
echo "Prod Cluster: $PROD_CLUSTER_NAME"
echo "Dev ECR: $ECR_DEV_URL"
echo "Prod ECR: $ECR_PROD_URL"
echo "GitHub Actions Role ARN: $GITHUB_ROLE_ARN"
echo "Bastion IP: $BASTION_IP"

echo "=== Updating kubeconfig ==="
aws eks update-kubeconfig --region $AWS_REGION --name $DEV_CLUSTER_NAME --alias dev-cluster
aws eks update-kubeconfig --region $AWS_REGION --name $PROD_CLUSTER_NAME --alias prod-cluster

echo "=== Next steps ==="
echo "1. Create GitHub repository: $GITHUB_ORG/day2-product"
echo "2. Copy day2-product/* to your repository"
echo "3. Update the repository URLs in ArgoCD application files:"
echo "   - app-files/argocd/dev-application.yaml"
echo "   - app-files/argocd/prod-application.yaml"
echo "4. Set GitHub secrets:"
echo "   - AWS_ROLE_ARN: $GITHUB_ROLE_ARN"
echo "   - ARGOCD_SERVER: <argocd-server-url>"
echo "   - ARGOCD_AUTH_TOKEN: <argocd-auth-token>"
echo "5. Create GitHub PAT and update app-files/actions-runner-controller/actions-runner-controller.yaml"
echo "6. Deploy components using Helm (ArgoCD, Argo Rollouts, Actions Runner Controller):"
echo "   - See app-files/ directories for manifests"
echo "7. Deploy AWS Load Balancer Controller:"
echo "   - Service accounts are already created by Terraform"
echo "   - Use Helm to deploy the controller"
echo "8. SSH to bastion: ssh -i cicd-key ec2-user@$BASTION_IP"
