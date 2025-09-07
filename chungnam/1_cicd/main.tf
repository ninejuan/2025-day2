module "vpc" {
  source = "./modules/vpc"

  cluster_name          = var.cluster_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_count   = var.public_subnet_count
  private_subnet_count  = var.private_subnet_count
  enable_nat_gateway    = var.enable_nat_gateway
  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.ecr_repository_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  
  node_group_name     = var.node_group_name
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_max_size       = var.node_max_size
  node_min_size       = var.node_min_size

  depends_on = [module.vpc]
}

module "alb" {
  source = "./modules/alb"

  alb_name          = var.alb_name
  vpc_id            = module.vpc.vpc_id
  public_subnets    = module.vpc.public_subnets
  cluster_name      = var.cluster_name
  oidc_provider_url = module.eks.oidc_provider_url

  depends_on = [module.eks, module.vpc]
}