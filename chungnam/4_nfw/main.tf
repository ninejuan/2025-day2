# Read the public key file
locals {
  public_key_content = file("${path.module}/nfw-key.pub")
}

# 방화벽 엔드포인트(AZ별) 맵으로 변환 (set → map)
locals {
  nfw_endpoint_map = { for s in module.network_firewall.firewall_endpoints : s.availability_zone => s.attachment[0].endpoint_id }
}

# 아래 IGW 라우트테이블/연결은 본 과제 스펙에 필요하지 않아 주석 처리함
# (퍼블릭 RT는 이미 IGW로 0.0.0.0/0 라우트를 갖고 있으며,
#  인바운드용 IGW 전용 RT는 불필요)
# resource "aws_route_table" "igw_route_table" {
#   vpc_id = module.egress_vpc.vpc_id
#   tags = { Name = "${var.project_name}-igw-rt" }
# }
# resource "aws_route_table_association" "igw_association" {
#   gateway_id     = module.egress_vpc.internet_gateway_id
#   route_table_id = aws_route_table.igw_route_table.id
# }

# Egress VPC
module "egress_vpc" {
  source = "./modules/vpc"

  vpc_name           = "${var.project_name}-egress-vpc"
  cidr_block         = var.egress_vpc_cidr
  availability_zones = var.availability_zones
  create_igw         = true
  create_nat_gw      = true

  public_subnets = var.egress_public_subnets
  public_subnet_names = [
    "${var.project_name}-egress-public-sn-a",
    "${var.project_name}-egress-public-sn-b"
  ]

  peering_subnets = var.egress_peering_subnets
  peering_subnet_names = [
    "${var.project_name}-egress-peering-sn-a",
    "${var.project_name}-egress-peering-sn-b"
  ]

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

  private_subnets = var.app_private_subnets
  private_subnet_names = [
    "${var.project_name}-app-private-sn-a",
    "${var.project_name}-app-private-sn-b"
  ]
}

# Transit Gateway for centralized internet egress via NFW
resource "aws_ec2_transit_gateway" "main" {
  description = "Transit Gateway for NFW internet egress"

  tags = {
    Name = "${var.project_name}-tgw"
  }
}

# TGW Attachment for Egress VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "egress" {
  subnet_ids                                      = module.egress_vpc.peering_subnet_ids
  transit_gateway_id                             = aws_ec2_transit_gateway.main.id
  vpc_id                                         = module.egress_vpc.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support                          = "enable"

  tags = {
    Name = "${var.project_name}-egress-tgw-attachment"
  }
}

# TGW Attachment for App VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "app" {
  subnet_ids                                      = module.app_vpc.private_subnet_ids
  transit_gateway_id                             = aws_ec2_transit_gateway.main.id
  vpc_id                                         = module.app_vpc.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support                          = "enable"

  tags = {
    Name = "${var.project_name}-app-tgw-attachment"
  }
}

# TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "${var.project_name}-tgw-rt"
  }
}

# TGW Route Table Association for Egress VPC
resource "aws_ec2_transit_gateway_route_table_association" "egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# TGW Route Table Association for App VPC
resource "aws_ec2_transit_gateway_route_table_association" "app" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# TGW Route Table Propagation for Egress VPC
resource "aws_ec2_transit_gateway_route_table_propagation" "egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# TGW Route Table Propagation for App VPC
resource "aws_ec2_transit_gateway_route_table_propagation" "app" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# 기존 VPC Peering Connection은 주석 처리
# resource "aws_vpc_peering_connection" "app_to_egress" {
#   peer_vpc_id = module.egress_vpc.vpc_id
#   vpc_id      = module.app_vpc.vpc_id
#   auto_accept = true
#   tags = { Name = "${var.project_name}-app-to-egress-peering" }
# }

module "network_firewall" {
  source = "./modules/network_firewall"

  firewall_name       = "${var.project_name}-firewall"
  vpc_id              = module.egress_vpc.vpc_id
  firewall_subnet_ids = module.egress_vpc.firewall_subnet_ids
  home_net_cidrs      = [var.egress_vpc_cidr, var.app_vpc_cidr]
}

# Bastion은 App VPC 프라이빗 서브넷에 위치(SSM 접속 가정). EIP 불필요
module "bastion" {
  source = "./modules/bastion"

  instance_name      = "app-bastion"
  vpc_id             = module.app_vpc.vpc_id
  subnet_id          = module.app_vpc.private_subnet_ids[0]
  key_pair_name      = var.key_pair_name
  public_key_content = local.public_key_content
}

# 아래 Bastion EIP 구성은 스펙과 불일치하여 주석 처리함
# resource "aws_eip" "bastion_eip" {
#   domain = "vpc"
#   tags = { Name = "app-bastion-eip" }
#   depends_on = [module.egress_vpc]
# }
# resource "aws_eip_association" "bastion_eip_assoc" {
#   instance_id   = module.bastion.instance_id
#   allocation_id = aws_eip.bastion_eip.id
# }


# 기존 Peering 관련 라우팅들도 주석 처리
# resource "aws_route" "app_to_egress" {
#   count                     = length(module.app_vpc.private_route_table_ids)
#   route_table_id            = module.app_vpc.private_route_table_ids[count.index]
#   destination_cidr_block    = "0.0.0.0/0"
#   vpc_peering_connection_id = aws_vpc_peering_connection.app_to_egress.id
# }

# resource "aws_route" "egress_peering_to_app" {
#   count                     = length(module.egress_vpc.peering_route_table_ids)
#   route_table_id            = module.egress_vpc.peering_route_table_ids[count.index]
#   destination_cidr_block    = var.app_vpc_cidr
#   vpc_peering_connection_id = aws_vpc_peering_connection.app_to_egress.id
# }

## AZ 매칭 없이 인덱스로 엔드포인트를 선택하던 기존 구성은 불안정하여 주석 처리
# resource "aws_route" "egress_peering_to_firewall" {
#   count                  = length(module.egress_vpc.peering_route_table_ids)
#   route_table_id         = module.egress_vpc.peering_route_table_ids[count.index]
#   destination_cidr_block = "0.0.0.0/0"
#   vpc_endpoint_id        = tolist(module.network_firewall.firewall_endpoints)[count.index]["attachment"][0]["endpoint_id"]
# }

# 기존 라우팅 리소스들을 주석 처리 (중복 방지)
# resource "aws_route" "egress_peering_to_firewall" {
#   count                  = length(module.egress_vpc.peering_route_table_ids)
#   route_table_id         = module.egress_vpc.peering_route_table_ids[count.index]
#   destination_cidr_block = "0.0.0.0/0"
#   vpc_endpoint_id        = local.nfw_endpoint_map[var.availability_zones[count.index]]
# }

# resource "aws_route" "firewall_to_nat" {
#   count          = length(module.egress_vpc.firewall_route_table_ids)
#   route_table_id = module.egress_vpc.firewall_route_table_ids[count.index]
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id = module.egress_vpc.nat_gateway_ids[count.index]
# }

# resource "aws_route" "firewall_to_app" {
#   count                     = length(module.egress_vpc.firewall_route_table_ids)
#   route_table_id            = module.egress_vpc.firewall_route_table_ids[count.index]
#   destination_cidr_block    = var.app_vpc_cidr
#   vpc_peering_connection_id = aws_vpc_peering_connection.app_to_egress.id
# }

# 아래 IGW RT 관련 라우트들도 함께 주석 처리(불필요)
# resource "aws_route" "igw_to_app_via_firewall" {
#   route_table_id         = aws_route_table.igw_route_table.id
#   destination_cidr_block = var.app_vpc_cidr
#   vpc_endpoint_id        = tolist(module.network_firewall.firewall_endpoints)[0]["attachment"][0]["endpoint_id"]
# }
# resource "aws_route" "igw_to_peering_via_firewall" {
#   count                  = length(var.egress_peering_subnets)
#   route_table_id         = aws_route_table.igw_route_table.id
#   destination_cidr_block = var.egress_peering_subnets[count.index]
#   vpc_endpoint_id        = tolist(module.network_firewall.firewall_endpoints)[count.index]["attachment"][0]["endpoint_id"]
# }

# Public Route Table to App VPC via firewall  
## 아래 퍼블릭 RT -> 방화벽 엔드포인트 경로는 불필요하므로 주석 처리
# resource "aws_route" "public_to_app_via_firewall" {
#   route_table_id         = module.egress_vpc.public_route_table_id
#   destination_cidr_block = var.app_vpc_cidr
#   vpc_endpoint_id        = tolist(module.network_firewall.firewall_endpoints)[0]["attachment"][0]["endpoint_id"]
# }
# resource "aws_route" "public_to_peering_via_firewall" {
#   count                  = length(var.egress_peering_subnets)
#   route_table_id         = module.egress_vpc.public_route_table_id
#   destination_cidr_block = var.egress_peering_subnets[count.index]
#   vpc_endpoint_id        = tolist(module.network_firewall.firewall_endpoints)[count.index]["attachment"][0]["endpoint_id"]
# }

# 퍼블릭 RT에 App VPC CIDR로 가는 경로를 Peering으로 추가 (NAT 응답 경로 확보)
# 기존 Peering 관련 라우팅은 주석 처리하고 TGW 기반으로 교체
# resource "aws_route" "app_to_egress" {
#   count                     = length(module.app_vpc.private_route_table_ids)
#   route_table_id            = module.app_vpc.private_route_table_ids[count.index]
#   destination_cidr_block    = "0.0.0.0/0"
#   vpc_peering_connection_id = aws_vpc_peering_connection.app_to_egress.id
# }

# App VPC Private Subnet -> TGW 라우팅
resource "aws_route" "app_to_tgw" {
  count                     = length(module.app_vpc.private_route_table_ids)
  route_table_id            = module.app_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = "0.0.0.0/0"
  transit_gateway_id        = aws_ec2_transit_gateway.main.id
}

# Egress VPC Peering Subnet -> TGW 라우팅 (기존 방화벽 라우팅과 충돌하므로 주석 처리)
# resource "aws_route" "egress_peering_to_tgw" {
#   count                     = length(module.egress_vpc.peering_route_table_ids)
#   route_table_id            = module.egress_vpc.peering_route_table_ids[count.index]
#   destination_cidr_block    = "0.0.0.0/0"
#   transit_gateway_id        = aws_ec2_transit_gateway.main.id
# }

# 기존 라우팅들도 주석 처리
# resource "aws_route" "egress_peering_to_app" {
#   count                     = length(module.egress_vpc.peering_route_table_ids)
#   route_table_id            = module.egress_vpc.peering_route_table_ids[count.index]
#   destination_cidr_block    = var.app_vpc_cidr
#   vpc_peering_connection_id = aws_vpc_peering_connection.app_to_egress.id
# }

# Egress VPC Peering Subnet -> NFW 라우팅 (TGW를 통해 들어온 트래픽을 NFW로)
resource "aws_route" "egress_peering_to_firewall" {
  count                  = length(module.egress_vpc.peering_route_table_ids)
  route_table_id         = module.egress_vpc.peering_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.nfw_endpoint_map[var.availability_zones[count.index]]
}

# NFW -> NAT Gateway 라우팅 (인터넷 이그레스)
resource "aws_route" "firewall_to_nat" {
  count          = length(module.egress_vpc.firewall_route_table_ids)
  route_table_id = module.egress_vpc.firewall_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = module.egress_vpc.nat_gateway_ids[count.index]
}

# NFW -> App VPC 라우팅 (응답 트래픽)
resource "aws_route" "firewall_to_app" {
  count                     = length(module.egress_vpc.firewall_route_table_ids)
  route_table_id            = module.egress_vpc.firewall_route_table_ids[count.index]
  destination_cidr_block    = var.app_vpc_cidr
  transit_gateway_id        = aws_ec2_transit_gateway.main.id
}

# TGW 라우팅 테이블에 NFW를 경유한 인터넷 이그레스 라우트 추가
resource "aws_ec2_transit_gateway_route" "app_to_internet_via_nfw" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  blackhole                      = false
}

# TGW 라우팅 테이블에 App VPC로의 라우트 추가
resource "aws_ec2_transit_gateway_route" "egress_to_app" {
  destination_cidr_block         = var.app_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
  blackhole                      = false
}

# Public Route Table -> App VPC CIDR via NFW endpoint (AZ별 대칭 경로)
resource "aws_route" "public_to_app_via_firewall" {
  count                  = length(module.egress_vpc.public_route_table_ids)
  route_table_id         = module.egress_vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.app_vpc_cidr
  vpc_endpoint_id        = local.nfw_endpoint_map[var.availability_zones[count.index]]
}

