output "service_network_id" {
  description = "VPC Lattice 서비스 네트워크 ID"
  value       = aws_vpclattice_service_network.main.id
}

output "service_network_name" {
  description = "VPC Lattice 서비스 네트워크 이름"
  value       = aws_vpclattice_service_network.main.name
}

output "target_group_id" {
  description = "Target Group ID"
  value       = aws_vpclattice_target_group.main.id
}

output "service_id" {
  description = "VPC Lattice 서비스 ID"
  value       = aws_vpclattice_service.main.id
}

output "service_name" {
  description = "VPC Lattice 서비스 이름"
  value       = aws_vpclattice_service.main.name
}

output "service_dns_name" {
  description = "VPC Lattice 서비스 DNS 이름"
  value       = aws_vpclattice_service.main.dns_entry[0].domain_name
}
