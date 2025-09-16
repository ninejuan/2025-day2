output "service_network_arn" {
  description = "ARN of the VPC Lattice service network"
  value       = aws_vpclattice_service_network.main.arn
}

output "service_network_id" {
  description = "ID of the VPC Lattice service network"
  value       = aws_vpclattice_service_network.main.id
}

output "service_arn" {
  description = "ARN of the VPC Lattice service"
  value       = aws_vpclattice_service.main.arn
}

output "service_dns_name" {
  description = "DNS name of the VPC Lattice service"
  value       = aws_vpclattice_service.main.dns_entry[0].domain_name
}

output "target_group_arn" {
  description = "ARN of the VPC Lattice target group"
  value       = aws_vpclattice_target_group.alb.arn
}
