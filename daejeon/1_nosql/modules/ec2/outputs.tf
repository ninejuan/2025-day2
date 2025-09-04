output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_eip.main.public_ip
}

output "private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.main.private_ip
}

output "key_name" {
  description = "EC2 key pair name"
  value       = aws_key_pair.ec2_key.key_name
}
