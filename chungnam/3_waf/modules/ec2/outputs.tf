output "instance_id" {
  description = "App server instance ID"
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "App server public IP"
  value       = aws_instance.app_server.public_ip
}

output "private_ip" {
  description = "App server private IP"
  value       = aws_instance.app_server.private_ip
}

output "security_group_id" {
  description = "App server security group ID"
  value       = aws_security_group.app_server.id
}
