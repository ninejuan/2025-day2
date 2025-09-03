output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR 블록"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public 서브넷 ID들"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private 서브넷 ID들"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway ID들"
  value       = aws_nat_gateway.main[*].id
}
