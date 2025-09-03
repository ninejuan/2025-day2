output "public_ip" {
  description = "Github Actions Runner 공인 IP"
  value       = aws_instance.github_runner.public_ip
}

output "private_ip" {
  description = "Github Actions Runner 사설 IP"
  value       = aws_instance.github_runner.private_ip
}

output "instance_id" {
  description = "Github Actions Runner 인스턴스 ID"
  value       = aws_instance.github_runner.id
}

output "iam_role_arn" {
  description = "Github Actions Runner IAM 역할 ARN"
  value       = aws_iam_role.github_runner.arn
}
