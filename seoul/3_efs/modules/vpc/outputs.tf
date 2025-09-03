output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public 서브넷 ID들"
  value       = { for k, v in var.public_subnets : k => aws_subnet.public[index(keys(var.public_subnets), k)].id }
}

output "private_subnet_ids" {
  description = "Private 서브넷 ID들"
  value       = { for k, v in var.private_subnets : k => aws_subnet.private[index(keys(var.private_subnets), k)].id }
}

output "efs_security_group_id" {
  description = "EFS 보안 그룹 ID"
  value       = aws_security_group.efs.id
}

output "app_security_group_id" {
  description = "App 인스턴스 보안 그룹 ID"
  value       = aws_security_group.app.id
}

output "bastion_security_group_id" {
  description = "Bastion 호스트 보안 그룹 ID"
  value       = aws_security_group.bastion.id
}
