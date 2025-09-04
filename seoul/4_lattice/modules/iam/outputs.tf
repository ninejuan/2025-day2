output "role_id" {
  description = "IAM 역할 ID"
  value       = aws_iam_role.main.id
}

output "role_name" {
  description = "IAM 역할 이름"
  value       = aws_iam_role.main.name
}

output "role_arn" {
  description = "IAM 역할 ARN"
  value       = aws_iam_role.main.arn
}

output "instance_profile_name" {
  description = "IAM 인스턴스 프로필 이름"
  value       = aws_iam_instance_profile.main.name
}
