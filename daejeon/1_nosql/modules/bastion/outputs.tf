output "bastion_instance_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Bastion private IP"
  value       = aws_instance.bastion.private_ip
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = var.bastion_security_group_id
}

output "bastion_key_name" {
  description = "Bastion key pair name"
  value       = aws_key_pair.bastion.key_name
}
