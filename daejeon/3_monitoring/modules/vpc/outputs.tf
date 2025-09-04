output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.wsi_vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.wsi_pub_sn_a.id, aws_subnet.wsi_pub_sn_c.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.wsi_priv_sn_a.id, aws_subnet.wsi_priv_sn_c.id]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.wsi_igw.id
}
