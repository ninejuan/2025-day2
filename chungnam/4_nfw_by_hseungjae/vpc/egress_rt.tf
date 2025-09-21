# Hub VPC Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = module.egress_vpc.vpc_id
  tags = {
    Name = "${var.prefix}-egress-public-rt"
  }
}

resource "aws_route_table" "peering_route_table_a" {
  vpc_id = module.egress_vpc.vpc_id
  tags = {
    Name = "${var.prefix}-egress-peering-rt-a"
  }
}

resource "aws_route_table" "peering_route_table_b" {
  vpc_id = module.egress_vpc.vpc_id
  tags = {
    Name = "${var.prefix}-egress-peering-rt-b"
  }
}

resource "aws_route_table" "firewall_route_table_a" {
  vpc_id = module.egress_vpc.vpc_id
  tags = {
    Name = "${var.prefix}-egress-firewall-rt-a"
  }
}

resource "aws_route_table" "firewall_route_table_b" {
  vpc_id = module.egress_vpc.vpc_id
  tags = {
    Name = "${var.prefix}-egress-firewall-rt-b"
  }
}

# Route Table Associations - egress
resource "aws_route_table_association" "public_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "peering_association_a" {
  subnet_id      = aws_subnet.peering_subnet_a.id
  route_table_id = aws_route_table.peering_route_table_a.id
}

resource "aws_route_table_association" "peering_association_b" {
  subnet_id      = aws_subnet.peering_subnet_b.id
  route_table_id = aws_route_table.peering_route_table_b.id
}

resource "aws_route_table_association" "firewall_association_a" {
  subnet_id      = aws_subnet.firewall_subnet_a.id
  route_table_id = aws_route_table.firewall_route_table_a.id
}

resource "aws_route_table_association" "firewall_association_b" {
  subnet_id      = aws_subnet.firewall_subnet_b.id
  route_table_id = aws_route_table.firewall_route_table_b.id
}

# routes - igw
resource "aws_route" "public_route_igw" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.egress_igw.id
}

# routes - ngw
resource "aws_route" "firewall_route_ngw_a" {
  route_table_id         = aws_route_table.firewall_route_table_a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.egress_ngw_a.id
}

resource "aws_route" "firewall_route_ngw_b" {
  route_table_id         = aws_route_table.firewall_route_table_b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.egress_ngw_b.id
}

# routes - tgw
resource "aws_route" "peering_route_tgw_connection_a" {
  route_table_id            = aws_route_table.peering_route_table_a.id
  destination_cidr_block    = "172.16.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "peering_route_tgw_connection_b" {
  route_table_id            = aws_route_table.peering_route_table_b.id
  destination_cidr_block    = "172.16.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "firewall_route_tgw_connection_a" {
  route_table_id            = aws_route_table.firewall_route_table_a.id
  destination_cidr_block    = "172.16.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "firewall_route_tgw_connection_b" {
  route_table_id            = aws_route_table.firewall_route_table_b.id
  destination_cidr_block    = "172.16.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

# routes - firewall
resource "aws_route" "public_route_firewall_a" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "172.16.0.0/16"
  vpc_endpoint_id        = local.firewall_endpoints_by_az[var.availability_zones[0]]
}

resource "aws_route" "peering_route_firewall_a" {
  route_table_id         = aws_route_table.peering_route_table_a.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoints_by_az[var.availability_zones[0]]
}

resource "aws_route" "peering_route_firewall_b" {
  route_table_id         = aws_route_table.peering_route_table_b.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoints_by_az[var.availability_zones[1]]
}