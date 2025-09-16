output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  description = "Public IP of bastion server"
  value       = module.bastion.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "ecr_app_repository_url" {
  description = "ECR repository URL for app"
  value       = module.ecr.app_repository_url
}

output "ecr_firelens_repository_url" {
  description = "ECR repository URL for firelens"
  value       = module.ecr.firelens_repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.cloudwatch.log_group_name
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS security group"
  value       = aws_security_group.ecs.id
}
