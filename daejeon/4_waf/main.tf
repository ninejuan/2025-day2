terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      Project     = "WAF-XXE-Protection"
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  name_prefix = "xxe"
  common_tags = {
    Project     = "WAF-XXE-Protection"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_key_pair" "waf_keypair" {
  key_name   = "waf-keypair"
  public_key = file("${path.module}/waf-key.pub")
  
  tags = merge(local.common_tags, {
    Name = "waf-keypair"
  })
}

module "bastion" {
  source = "./modules/bastion"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  vpc_id = data.aws_vpc.default.id
  public_subnet_ids = data.aws_subnets.default.ids
  key_name = aws_key_pair.waf_keypair.key_name
}

module "ec2" {
  source = "./modules/ec2"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  vpc_id = data.aws_vpc.default.id
  public_subnet_ids = data.aws_subnets.default.ids
  key_name = aws_key_pair.waf_keypair.key_name
}

module "alb" {
  source = "./modules/alb"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  vpc_id = data.aws_vpc.default.id
  public_subnet_ids = data.aws_subnets.default.ids
  ec2_instance_id = module.ec2.instance_id
}

module "waf" {
  source = "./modules/waf"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  alb_arn = module.alb.alb_arn
}
