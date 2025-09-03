output "repository_url" {
  description = "ECR 레포지토리 URL"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_name" {
  description = "ECR 레포지토리 이름"
  value       = aws_ecr_repository.main.name
}

output "repository_arn" {
  description = "ECR 레포지토리 ARN"
  value       = aws_ecr_repository.main.arn
}
