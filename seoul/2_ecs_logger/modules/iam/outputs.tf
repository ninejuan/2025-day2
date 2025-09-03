output "ecs_task_execution_role_arn" {
  description = "ECS Task Execution 역할 ARN"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_execution_role_name" {
  description = "ECS Task Execution 역할 이름"
  value       = aws_iam_role.ecs_task_execution_role.name
}
