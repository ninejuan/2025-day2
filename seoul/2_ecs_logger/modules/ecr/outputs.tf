output "ecr_repository_url" {
  description = "ECR 리포지토리 URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "ECR 리포지토리 이름"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_arn" {
  description = "ECR 리포지토리 ARN"
  value       = aws_ecr_repository.app.arn
}

output "docker_build_push" {
  description = "Docker 이미지 빌드 및 푸시 완료 신호"
  value       = null_resource.docker_build_push
}
