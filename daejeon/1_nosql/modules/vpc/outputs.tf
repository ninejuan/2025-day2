output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "security_group_id" {
  description = "Security group ID for EC2"
  value       = aws_security_group.ec2.id
}

output "bastion_security_group_id" {
  description = "Security group ID for Bastion"
  value       = aws_security_group.bastion.id
}
