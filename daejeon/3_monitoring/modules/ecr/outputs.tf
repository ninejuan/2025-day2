output "repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.wsi_repo.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.wsi_repo.arn
}

output "docker_build_complete" {
  description = "Indicates that Docker build and push is complete"
  value       = null_resource.docker_build_push.id
}
