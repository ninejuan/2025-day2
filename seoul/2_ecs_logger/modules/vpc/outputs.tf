output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR 블록"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID들"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록들"
  value       = aws_subnet.public[*].cidr_block
}

output "internet_gateway_id" {
  description = "인터넷 게이트웨이 ID"
  value       = aws_internet_gateway.main.id
}

output "ecs_tasks_security_group_id" {
  description = "ECS Tasks 보안 그룹 ID"
  value       = aws_security_group.ecs_tasks.id
}

output "bastion_security_group_id" {
  description = "Bastion Host 보안 그룹 ID"
  value       = aws_security_group.bastion.id
}
