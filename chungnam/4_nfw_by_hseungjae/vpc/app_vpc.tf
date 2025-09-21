// App VPC Configuration
module "app_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "${var.prefix}-app-vpc"
  cidr = "172.16.0.0/16"

  map_public_ip_on_launch = true
  enable_nat_gateway      = false
}

resource "aws_subnet" "app_subnet_a" {
  vpc_id                  = module.app_vpc.vpc_id
  cidr_block              = "172.16.0.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-app-private-sn-a"
  }
}

resource "aws_subnet" "app_subnet_b" {
  vpc_id                  = module.app_vpc.vpc_id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-app-private-sn-b"
  }
}