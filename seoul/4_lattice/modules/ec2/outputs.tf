output "instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.instance.id
}

output "private_ip" {
  description = "EC2 인스턴스 Private IP"
  value       = aws_instance.instance.private_ip
}

output "public_ip" {
  description = "EC2 인스턴스 Public IP"
  value       = aws_instance.instance.public_ip
}

output "eip_public_ip" {
  description = "Elastic IP Public IP"
  value       = var.create_eip ? aws_eip.eip[0].public_ip : null
}
