output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_eip.bastion.public_ip
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.bastion.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.bastion.id
}
