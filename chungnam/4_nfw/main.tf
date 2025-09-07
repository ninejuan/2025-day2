# Read the public key file
locals {
  public_key_content = file("${path.module}/nfw-key.pub")
}

# Egress VPC
module "egress_vpc" {
  source = "./modules/vpc"

  vpc_name           = "${var.project_name}-egress-vpc"
  cidr_block         = var.egress_vpc_cidr
  availability_zones = var.availability_zones
  create_igw         = true
  create_nat_gw      = true

  # Public subnets
  public_subnets = var.egress_public_subnets
  public_subnet_names = [
    "${var.project_name}-egress-public-sn-a",
    "${var.project_name}-egress-public-sn-b"
  ]

  # Peering subnets
  peering_subnets = var.egress_peering_subnets
  peering_subnet_names = [
    "${var.project_name}-egress-peering-sn-a",
    "${var.project_name}-egress-peering-sn-b"
  ]

  # Firewall subnets
  firewall_subnets = var.egress_firewall_subnets
  firewall_subnet_names = [
    "${var.project_name}-egress-firewall-sn-a",
    "${var.project_name}-egress-firewall-sn-b"
  ]
}

# App VPC
module "app_vpc" {
  source = "./modules/vpc"

  vpc_name           = "${var.project_name}-app-vpc"
  cidr_block         = var.app_vpc_cidr
  availability_zones = var.availability_zones
  create_igw         = false
  create_nat_gw      = false

  # Private subnets
  private_subnets = var.app_private_subnets
  private_subnet_names = [
    "${var.project_name}-app-private-sn-a",
    "${var.project_name}-app-private-sn-b"
  ]
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "app_to_egress" {
  peer_vpc_id = module.egress_vpc.vpc_id
  vpc_id      = module.app_vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "${var.project_name}-app-to-egress-peering"
  }
}

# Network Firewall
module "network_firewall" {
  source = "./modules/network_firewall"

  firewall_name       = "${var.project_name}-firewall"
  vpc_id              = module.egress_vpc.vpc_id
  firewall_subnet_ids = module.egress_vpc.firewall_subnet_ids
  home_net_cidrs      = [var.egress_vpc_cidr, var.app_vpc_cidr]
}

# Bastion Host in App VPC
module "bastion" {
  source = "./modules/bastion"

  instance_name      = "app-bastion"
  vpc_id             = module.app_vpc.vpc_id
  subnet_id          = module.app_vpc.private_subnet_ids[0]
  key_pair_name      = var.key_pair_name
  public_key_content = local.public_key_content
}

# Route Tables Configuration

# Routes from App VPC private subnets to Egress VPC via peering
resource "aws_route" "app_to_egress" {
  count                     = length(module.app_vpc.private_route_table_ids)
  route_table_id            = module.app_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = "0.0.0.0/0"
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_egress.id
}

# Routes from Egress VPC peering subnets to App VPC
resource "aws_route" "egress_peering_to_app" {
  count                     = length(module.egress_vpc.peering_route_table_ids)
  route_table_id            = module.egress_vpc.peering_route_table_ids[count.index]
  destination_cidr_block    = var.app_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_egress.id
}

# Routes from Egress VPC peering subnets to firewall endpoints
resource "aws_route" "egress_peering_to_firewall" {
  count              = length(module.egress_vpc.peering_route_table_ids)
  route_table_id     = module.egress_vpc.peering_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id    = tolist(module.network_firewall.firewall_endpoints)[count.index]["attachment"][0]["endpoint_id"]
}

# Routes from Egress VPC firewall subnets to NAT Gateway
resource "aws_route" "firewall_to_nat" {
  count          = length(module.egress_vpc.firewall_route_table_ids)
  route_table_id = module.egress_vpc.firewall_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = module.egress_vpc.nat_gateway_ids[count.index]
}

# Routes from Egress VPC firewall subnets back to App VPC via peering connection
resource "aws_route" "firewall_to_app" {
  count                     = length(module.egress_vpc.firewall_route_table_ids)
  route_table_id            = module.egress_vpc.firewall_route_table_ids[count.index]
  destination_cidr_block    = var.app_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.app_to_egress.id
}

