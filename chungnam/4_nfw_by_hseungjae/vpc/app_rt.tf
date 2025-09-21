# App VPC Route Table
resource "aws_route_table" "app_route_table_a" {
  vpc_id = module.app_vpc.vpc_id
  tags = {
    Name = "${var.prefix}-app-rt-a"
  }
}

resource "aws_route_table" "app_route_table_b" {
  vpc_id = module.app_vpc.vpc_id
  tags = {
    Name = "${var.prefix}-app-rt-b"
  }
}

# Route Table Associations - app
resource "aws_route_table_association" "app_association_a" {
  subnet_id      = aws_subnet.app_subnet_a.id
  route_table_id = aws_route_table.app_route_table_a.id
}

resource "aws_route_table_association" "app_association_b" {
  subnet_id      = aws_subnet.app_subnet_b.id
  route_table_id = aws_route_table.app_route_table_b.id
}

# routes - tgw
resource "aws_route" "app_route_tgw_connection_a" {
  route_table_id         = aws_route_table.app_route_table_a.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "app_route_tgw_connection_b" {
  route_table_id         = aws_route_table.app_route_table_b.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}