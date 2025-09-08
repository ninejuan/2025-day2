output "app_repository_url" {
  description = "URL of the app ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "firelens_repository_url" {
  description = "URL of the firelens ECR repository"
  value       = aws_ecr_repository.firelens.repository_url
}

output "app_repository_name" {
  description = "Name of the app ECR repository"
  value       = aws_ecr_repository.app.name
}

output "firelens_repository_name" {
  description = "Name of the firelens ECR repository"
  value       = aws_ecr_repository.firelens.name
}

output "app_image_pushed" {
  description = "Trigger for when app image is pushed"
  value       = null_resource.build_and_push_app.id
}

output "firelens_image_pushed" {
  description = "Trigger for when firelens image is pushed"
  value       = null_resource.build_and_push_firelens.id
}
