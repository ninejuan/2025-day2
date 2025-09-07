output "egress_vpc_id" {
  description = "ID of the Egress VPC"
  value       = module.egress_vpc.vpc_id
}

output "app_vpc_id" {
  description = "ID of the App VPC"
  value       = module.app_vpc.vpc_id
}

output "network_firewall_id" {
  description = "ID of the Network Firewall"
  value       = module.network_firewall.firewall_id
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = module.bastion.instance_id
}

output "vpc_peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.app_to_egress.id
}
