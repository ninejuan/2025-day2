output "vpc_a_id" {
  description = "VPC A ID"
  value       = module.vpc_a.vpc_id
}

output "vpc_b_id" {
  description = "VPC B ID"
  value       = module.vpc_b.vpc_id
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = module.bastion.eip_public_ip
}

output "service_a_private_ip" {
  description = "Service A Private IP"
  value       = module.service_a.private_ip
}

output "service_b_private_ip" {
  description = "Service B Private IP"
  value       = module.service_b.private_ip
}

output "dynamodb_table_name" {
  description = "DynamoDB 테이블 이름"
  value       = aws_dynamodb_table.service_b_table.name
}

output "lattice_service_network_name" {
  description = "VPC Lattice 서비스 네트워크 이름"
  value       = module.lattice.service_network_name
}

output "lattice_service_name" {
  description = "VPC Lattice 서비스 이름"
  value       = module.lattice.service_name
}
