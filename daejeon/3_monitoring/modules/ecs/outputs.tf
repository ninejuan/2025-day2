output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.wsi_cluster.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.wsi_cluster.arn
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.wsi_service.name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.wsi_task.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.wsi_log_group.name
}
