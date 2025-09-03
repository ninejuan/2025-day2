output "key_name" {
  description = "SSH 키 페어 이름"
  value       = aws_key_pair.main.key_name
}

output "bastion_public_ip" {
  description = "Bastion 호스트 공인 IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Bastion 호스트 사설 IP"
  value       = aws_instance.bastion.private_ip
}

output "app1_private_ip" {
  description = "App 1 사설 IP"
  value       = aws_instance.app1.private_ip
}

output "app2_private_ip" {
  description = "App 2 사설 IP"
  value       = aws_instance.app2.private_ip
}

output "app_instance_ids" {
  description = "App 인스턴스 ID들"
  value       = [aws_instance.app1.id, aws_instance.app2.id]
}

output "bastion_instance_id" {
  description = "Bastion 인스턴스 ID"
  value       = aws_instance.bastion.id
}
