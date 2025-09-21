resource "aws_ec2_transit_gateway" "tgw" {
  default_route_table_association = "disable"

  tags = {
    "Name" = "${var.prefix}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "egress_tgw_attachment" {
  subnet_ids         = [aws_subnet.peering_subnet_a.id, aws_subnet.peering_subnet_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.egress_vpc.vpc_id

  tags = {
    "Name" = "${var.prefix}-egress-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app_tgw_attachment" {
  subnet_ids         = [aws_subnet.app_subnet_a.id, aws_subnet.app_subnet_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.app_vpc.vpc_id

  tags = {
    "Name" = "${var.prefix}-app-tgw-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table" "egress_tgw_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    "Name" = "${var.prefix}-egress-tgw-rtb"
  }
}

resource "aws_ec2_transit_gateway_route_table" "app_tgw_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    "Name" = "${var.prefix}-app-tgw-rtb"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "egress_tgw_route_table_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_tgw_route_table.id
}

resource "aws_ec2_transit_gateway_route_table_association" "app_tgw_route_table_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app_tgw_route_table.id
}

resource "aws_ec2_transit_gateway_route" "egress_tgw_route" {
  destination_cidr_block         = "172.16.0.0/16"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress_tgw_route_table.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app_tgw_attachment.id
}

resource "aws_ec2_transit_gateway_route" "app_tgw_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app_tgw_route_table.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress_tgw_attachment.id
}
