output "public_ip" {
  description = "Bastion 호스트 공인 IP"
  value       = aws_instance.bastion.public_ip
}

output "private_ip" {
  description = "Bastion 호스트 사설 IP"
  value       = aws_instance.bastion.private_ip
}

output "instance_id" {
  description = "Bastion 호스트 인스턴스 ID"
  value       = aws_instance.bastion.id
}

output "iam_role_arn" {
  description = "Bastion 호스트 IAM 역할 ARN"
  value       = aws_iam_role.bastion.arn
}
