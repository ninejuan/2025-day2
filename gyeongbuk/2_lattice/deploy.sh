#!/bin/bash

echo "Starting VPC Lattice deployment..."

if [ ! -f "terraform.tfvars" ]; then
    echo "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
fi

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform deployment..."
terraform plan

echo "Applying Terraform configuration..."
terraform apply -auto-approve

echo "Deployment completed!"
echo "Bastion IP: $(terraform output -raw bastion_public_ip)"
echo "Consumer ALB DNS: $(terraform output -raw consumer_alb_dns)"
