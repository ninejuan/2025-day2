output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public 서브넷 ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private 서브넷 ID"
  value       = aws_subnet.private.id
}

output "vpc_cidr" {
  description = "VPC CIDR 블록"
  value       = aws_vpc.main.cidr_block
}
