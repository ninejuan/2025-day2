output "instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "Public IP of the bastion instance"
  value       = aws_eip.bastion.public_ip
}

output "security_group_id" {
  description = "Security group ID of the bastion instance"
  value       = aws_security_group.bastion.id
}
