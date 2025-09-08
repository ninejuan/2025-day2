output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.runner.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_eip.runner_eip.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.runner.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.runner_sg.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.cluster_name}-runner-key.pem ec2-user@${aws_eip.runner_eip.public_ip}"
}
