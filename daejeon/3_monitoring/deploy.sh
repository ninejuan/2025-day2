#!/bin/bash

set -e

echo "🚀 Starting CloudWatch Monitoring deployment..."

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="ap-southeast-1"

echo "📋 AWS Account ID: $AWS_ACCOUNT_ID"
echo "🌏 AWS Region: $AWS_REGION"

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Plan Terraform
echo "📋 Planning Terraform deployment..."
terraform plan

# Apply Terraform
echo "🏗️ Applying Terraform configuration..."
terraform apply -auto-approve

# Get ECR repository URL
ECR_REPO_URL=$(terraform output -raw ecr_repository_url)
echo "📦 ECR Repository URL: $ECR_REPO_URL"
echo "🐳 Docker image will be built and pushed automatically by Terraform..."

# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "🌐 Application Load Balancer DNS: $ALB_DNS"

# Get Bastion IP
BASTION_IP=$(terraform output -raw bastion_public_ip)
echo "🖥️ Bastion Host IP: $BASTION_IP"

# Get CloudWatch Dashboard URL
DASHBOARD_URL=$(terraform output -raw cloudwatch_dashboard_url)
echo "📊 CloudWatch Dashboard URL: $DASHBOARD_URL"

echo "✅ Deployment completed successfully!"
echo ""
echo "🔗 Access URLs:"
echo "   Application: http://$ALB_DNS"
echo "   Health Check: http://$ALB_DNS/healthcheck"
echo "   Hello Endpoint: http://$ALB_DNS/hello"
echo "   Latency Test: http://$ALB_DNS/test_latency"
echo "   Latency Stats: http://$ALB_DNS/latency_stats"
echo ""
echo "🖥️ Bastion Host:"
echo "   SSH: ssh -i wsi-keypair ec2-user@$BASTION_IP"
echo ""
echo "📊 Monitoring:"
echo "   Dashboard: $DASHBOARD_URL"
echo ""
echo "🎉 All resources are now deployed and ready to use!"
