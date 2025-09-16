resource "aws_vpc_peering_connection" "main" {
  peer_vpc_id = var.peer_vpc_id
  vpc_id      = var.vpc_id
  auto_accept = true

  tags = {
    Name = var.peering_name
  }
}

resource "aws_route" "requester_private_to_peer" {
  count                     = length(var.requester_private_route_table_ids)
  route_table_id            = var.requester_private_route_table_ids[count.index]
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "requester_public_to_peer" {
  count                     = length(var.requester_public_route_table_ids)
  route_table_id            = var.requester_public_route_table_ids[count.index]
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "peer_private_to_requester" {
  count                     = length(var.peer_private_route_table_ids)
  route_table_id            = var.peer_private_route_table_ids[count.index]
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_route" "peer_public_to_requester" {
  count                     = length(var.peer_public_route_table_ids)
  route_table_id            = var.peer_public_route_table_ids[count.index]
  destination_cidr_block    = var.requester_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

resource "aws_security_group_rule" "requester_allow_peer" {
  count                    = var.enable_security_group_rules ? 1 : 0
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  cidr_blocks              = [var.peer_vpc_cidr]
  security_group_id        = var.requester_security_group_id
  description              = "Allow all traffic from peer VPC"
}

resource "aws_security_group_rule" "peer_allow_requester" {
  count                    = var.enable_security_group_rules ? 1 : 0
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  cidr_blocks              = [var.requester_vpc_cidr]
  security_group_id        = var.peer_security_group_id
  description              = "Allow all traffic from requester VPC"
}

resource "aws_vpc_peering_connection_options" "main" {
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id

  accepter {
    allow_remote_vpc_dns_resolution = var.enable_dns_resolution
  }

  requester {
    allow_remote_vpc_dns_resolution = var.enable_dns_resolution
  }
}
