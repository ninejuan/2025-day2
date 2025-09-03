output "bastion_public_ip" {
  description = "Bastion Host 공용 IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_id" {
  description = "Bastion Host 인스턴스 ID"
  value       = aws_instance.bastion.id
}

output "bastion_key_name" {
  description = "Bastion Host 키 페어 이름"
  value       = aws_key_pair.bastion.key_name
}
