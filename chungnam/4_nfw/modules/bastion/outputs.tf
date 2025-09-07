output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.bastion.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.bastion.arn
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.bastion.private_ip
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.bastion.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.bastion_sg.id
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = aws_key_pair.bastion_key.key_name
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.bastion_role.arn
}
