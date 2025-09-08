output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.main[*].id
}

output "private_ips" {
  description = "Private IPs of the EC2 instances"
  value       = aws_instance.main[*].private_ip
}

output "security_group_id" {
  description = "Security group ID of the EC2 instances"
  value       = aws_security_group.ec2.id
}
