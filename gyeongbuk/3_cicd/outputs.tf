output "dev_vpc_id" {
  description = "ID of the dev VPC"
  value       = module.dev_vpc.vpc_id
}

output "prod_vpc_id" {
  description = "ID of the prod VPC"
  value       = module.prod_vpc.vpc_id
}

output "dev_cluster_name" {
  description = "Name of the dev EKS cluster"
  value       = module.dev_eks.cluster_name
}

output "prod_cluster_name" {
  description = "Name of the prod EKS cluster"
  value       = module.prod_eks.cluster_name
}

output "dev_cluster_endpoint" {
  description = "Endpoint for dev EKS control plane"
  value       = module.dev_eks.cluster_endpoint
}

output "prod_cluster_endpoint" {
  description = "Endpoint for prod EKS control plane"
  value       = module.prod_eks.cluster_endpoint
}

output "dev_ecr_repository_url" {
  description = "URL of the dev ECR repository"
  value       = module.ecr.dev_repository_url
}

output "prod_ecr_repository_url" {
  description = "URL of the prod ECR repository"
  value       = module.ecr.prod_repository_url
}


output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.public_ip
}

output "dev_alb_dns_name" {
  description = "DNS name of the dev ALB"
  value       = module.dev_alb.alb_dns_name
}

output "prod_alb_dns_name" {
  description = "DNS name of the prod ALB"
  value       = module.prod_alb.alb_dns_name
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = module.kubernetes.github_actions_role_arn
}

output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection between dev and prod"
  value       = module.vpc_peering.peering_connection_id
}

output "vpc_peering_status" {
  description = "Status of the VPC peering connection"
  value       = module.vpc_peering.peering_connection_status
}
