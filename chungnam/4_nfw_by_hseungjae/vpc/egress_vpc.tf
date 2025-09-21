// Hub VPC Configuration
module "egress_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "${var.prefix}-egress-vpc"
  cidr = "10.0.0.0/16"

  map_public_ip_on_launch = true
  enable_nat_gateway      = false
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = module.egress_vpc.vpc_id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-egress-public-sn-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = module.egress_vpc.vpc_id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-egress-public-sn-b"
  }
}

resource "aws_subnet" "peering_subnet_a" {
  vpc_id                  = module.egress_vpc.vpc_id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-egress-peering-sn-a"
  }
}

resource "aws_subnet" "peering_subnet_b" {
  vpc_id                  = module.egress_vpc.vpc_id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-egress-peering-sn-b"
  }
}

resource "aws_subnet" "firewall_subnet_a" {
  vpc_id                  = module.egress_vpc.vpc_id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-egress-firewall-sn-a"
  }
}

resource "aws_subnet" "firewall_subnet_b" {
  vpc_id                  = module.egress_vpc.vpc_id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-egress-firewall-sn-b"
  }
}
