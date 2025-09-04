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
  region = "ap-southeast-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "wsi"
  common_tags = {
    Project     = "monitoring"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_key_pair" "wsi_keypair" {
  key_name   = "wsi-keypair"
  public_key = file("${path.module}/wsi-keypair.pub")

  tags = merge(local.common_tags, {
    Name = "wsi-keypair"
  })
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix        = local.name_prefix
  common_tags        = local.common_tags
  availability_zones = data.aws_availability_zones.available.names
}

module "ecr" {
  source = "./modules/ecr"

  name_prefix    = local.name_prefix
  common_tags    = local.common_tags
  app_files_path = "${path.module}/app-files"
}

module "bastion" {
  source = "./modules/bastion"

  name_prefix       = local.name_prefix
  common_tags       = local.common_tags
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  key_name          = aws_key_pair.wsi_keypair.key_name
}

module "alb" {
  source = "./modules/alb"

  name_prefix       = local.name_prefix
  common_tags       = local.common_tags
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix           = local.name_prefix
  common_tags           = local.common_tags
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_target_group_arn  = module.alb.target_group_arn
  alb_security_group_id = module.alb.security_group_id
  ecr_repository_url    = module.ecr.repository_url

  depends_on = [module.ecr.docker_build_complete]
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  name_prefix      = local.name_prefix
  common_tags      = local.common_tags
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  alb_name         = module.alb.alb_name
  alb_full_name    = module.alb.alb_full_name
}
