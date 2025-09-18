output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "peering_subnet_ids" {
  description = "IDs of the peering subnets"
  value       = aws_subnet.peering[*].id
}

output "firewall_subnet_ids" {
  description = "IDs of the firewall subnets"
  value       = aws_subnet.firewall[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.this[*].id
}

output "public_route_table_ids" {
  description = "IDs of the public route tables"
  value       = aws_route_table.public[*].id
}

output "peering_route_table_ids" {
  description = "IDs of the peering route tables"
  value       = aws_route_table.peering[*].id
}

output "firewall_route_table_ids" {
  description = "IDs of the firewall route tables"
  value       = aws_route_table.firewall[*].id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private[*].id
}
