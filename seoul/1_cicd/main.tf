terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_key_pair" "gac_ssh" {
  key_name   = "gac-ssh-key"
  public_key = file("${path.module}/gac-ssh-key.pub")
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones = var.availability_zones
}

module "kms" {
  source = "./modules/kms"
}

module "ecr" {
  source = "./modules/ecr"
  kms_key_id = module.kms.kms_key_id
}

module "eks" {
  source = "./modules/eks"
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  kms_key_id = module.kms.kms_key_arn
}

module "bastion" {
  source = "./modules/bastion"
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  instance_type = var.instance_type
  key_name = aws_key_pair.gac_ssh.key_name
  aws_region = var.aws_region
}

module "github_runner" {
  source = "./modules/github_runner"
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  instance_type = var.instance_type
  key_name = aws_key_pair.gac_ssh.key_name
  aws_region = var.aws_region
}