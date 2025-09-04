output "security_group_id" {
  description = "보안 그룹 ID"
  value       = aws_security_group.main.id
}

output "security_group_name" {
  description = "보안 그룹 이름"
  value       = aws_security_group.main.name
}
