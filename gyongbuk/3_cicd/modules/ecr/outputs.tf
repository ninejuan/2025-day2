output "dev_repository_url" {
  description = "The URL of the dev repository"
  value       = aws_ecr_repository.dev.repository_url
}

output "prod_repository_url" {
  description = "The URL of the prod repository"
  value       = aws_ecr_repository.prod.repository_url
}

output "dev_repository_arn" {
  description = "The ARN of the dev repository"
  value       = aws_ecr_repository.dev.arn
}

output "prod_repository_arn" {
  description = "The ARN of the prod repository"
  value       = aws_ecr_repository.prod.arn
}
