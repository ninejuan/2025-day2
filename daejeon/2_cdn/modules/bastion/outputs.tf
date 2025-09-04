output "bastion_instance_id" {
  description = "Bastion host 인스턴스 ID"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Bastion host 공개 IP"
  value       = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Bastion host 사설 IP"
  value       = aws_instance.bastion.private_ip
}

output "bastion_security_group_id" {
  description = "Bastion host 보안 그룹 ID"
  value       = aws_security_group.bastion.id
}

output "bastion_key_name" {
  description = "Bastion host 키 페어 이름"
  value       = aws_key_pair.bastion.key_name
}
