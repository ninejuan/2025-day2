output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.wsi_bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion instance"
  value       = aws_instance.wsi_bastion.public_ip
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.wsi_bastion_sg.id
}
