output "vpc_id" {
  description = "생성된 VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR 블록"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID들"
  value       = module.vpc.public_subnet_ids
}

output "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록들"
  value       = module.vpc.public_subnet_cidrs
}

output "internet_gateway_id" {
  description = "인터넷 게이트웨이 ID"
  value       = module.vpc.internet_gateway_id
}

output "ecr_repository_url" {
  description = "ECR 리포지토리 URL"
  value       = module.ecr.ecr_repository_url
}

output "ecr_repository_name" {
  description = "ECR 리포지토리 이름"
  value       = module.ecr.ecr_repository_name
}

output "ecs_cluster_name" {
  description = "ECS 클러스터 이름"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS 클러스터 ARN"
  value       = module.ecs.ecs_cluster_arn
}

output "ecs_service_name" {
  description = "ECS 서비스 이름"
  value       = module.ecs.ecs_service_name
}

output "ecs_task_definition_arn" {
  description = "ECS Task 정의 ARN"
  value       = module.ecs.ecs_task_definition_arn
}

output "alb_dns_name" {
  description = "ALB DNS 이름"
  value       = module.ecs.alb_dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.ecs.alb_arn
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = module.ecs.target_group_arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch 로그 그룹 이름"
  value       = module.ecs.cloudwatch_log_group_name
}

output "cloudwatch_alarm_name" {
  description = "CloudWatch 경보 이름"
  value       = module.cloudwatch.cloudwatch_alarm_name
}

output "bastion_public_ip" {
  description = "Bastion Host 공용 IP"
  value       = module.bastion.bastion_public_ip
}

output "bastion_instance_id" {
  description = "Bastion Host 인스턴스 ID"
  value       = module.bastion.bastion_instance_id
}

output "iam_role_name" {
  description = "ECS IAM 역할 이름"
  value       = module.iam.ecs_task_execution_role_name
}

output "iam_role_arn" {
  description = "ECS IAM 역할 ARN"
  value       = module.iam.ecs_task_execution_role_arn
}
