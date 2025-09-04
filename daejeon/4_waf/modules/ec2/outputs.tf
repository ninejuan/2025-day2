output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.xxe_server.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_eip.xxe_server_eip.public_ip
}

output "private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.xxe_server.private_ip
}

output "security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.ec2_sg.id
}
