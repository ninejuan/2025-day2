output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = module.bastion.public_ip
}

output "consumer_alb_dns" {
  description = "DNS name of consumer ALB"
  value       = module.consumer_alb.dns_name
}

output "lattice_service_network_arn" {
  description = "ARN of VPC Lattice service network"
  value       = module.lattice.service_network_arn
}

output "dynamodb_table_name" {
  description = "Name of DynamoDB table"
  value       = module.dynamodb.table_name
}

output "ecr_repository_url" {
  description = "URL of ECR repository"
  value       = module.ecr.repository_url
}
