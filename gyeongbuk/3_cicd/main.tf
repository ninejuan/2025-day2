module "dev_vpc" {
  source = "./modules/vpc"

  vpc_name               = "dev-vpc"
  vpc_cidr              = "10.0.0.0/16"
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
  cluster_name          = "dev-cluster"
}

module "prod_vpc" {
  source = "./modules/vpc"

  vpc_name               = "prod-vpc"
  vpc_cidr              = "10.1.0.0/16"
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs  = ["10.1.11.0/24", "10.1.12.0/24"]
  cluster_name          = "prod-cluster"
}

module "dev_eks" {
  source = "./modules/eks"

  cluster_name        = "dev-cluster"
  vpc_id              = module.dev_vpc.vpc_id
  subnet_ids          = module.dev_vpc.private_subnet_ids
  private_subnet_ids  = module.dev_vpc.private_subnet_ids
}

module "prod_eks" {
  source = "./modules/eks"

  cluster_name        = "prod-cluster"
  vpc_id              = module.prod_vpc.vpc_id
  subnet_ids          = module.prod_vpc.private_subnet_ids
  private_subnet_ids  = module.prod_vpc.private_subnet_ids
}

module "ecr" {
  source = "./modules/ecr"
}

resource "aws_key_pair" "cicd" {
  key_name   = var.key_name
  public_key = file("${path.module}/cicd-key.pub")
}


module "bastion" {
  source = "./modules/bastion"

  name              = "dev-bastion"
  vpc_id            = module.dev_vpc.vpc_id
  subnet_id         = module.dev_vpc.public_subnet_ids[0]
  key_name          = aws_key_pair.cicd.key_name
  dev_cluster_name  = module.dev_eks.cluster_name
  prod_cluster_name = module.prod_eks.cluster_name
  aws_region        = var.aws_region

  depends_on = [aws_key_pair.cicd]
}

module "dev_alb" {
  source = "./modules/alb"

  name       = "dev"
  vpc_id     = module.dev_vpc.vpc_id
  subnet_ids = module.dev_vpc.public_subnet_ids
}

module "prod_alb" {
  source = "./modules/alb"

  name       = "prod"
  vpc_id     = module.prod_vpc.vpc_id
  subnet_ids = module.prod_vpc.public_subnet_ids
}

resource "kubernetes_namespace" "dev_app" {
  provider = kubernetes.dev
  metadata {
    name = "app"
  }
}

resource "kubernetes_namespace" "prod_app" {
  provider = kubernetes.prod
  metadata {
    name = "app"
  }
}

resource "kubernetes_namespace" "dev_argocd" {
  provider = kubernetes.dev
  metadata {
    name = "argocd"
  }
}

module "kubernetes" {
  source = "./modules/kubernetes"

  providers = {
    kubernetes.dev  = kubernetes.dev
    kubernetes.prod = kubernetes.prod
  }

  github_org       = var.github_org
  github_repo      = var.github_repo
  dev_oidc_issuer  = module.dev_eks.cluster_oidc_issuer
  prod_oidc_issuer = module.prod_eks.cluster_oidc_issuer

  depends_on = [
    module.dev_eks,
    module.prod_eks,
    kubernetes_namespace.dev_app,
    kubernetes_namespace.prod_app,
    kubernetes_namespace.dev_argocd
  ]
}

module "vpc_peering" {
  source = "./modules/vpc-peering"

  peering_name = "dev-prod-vpc-peering"
  
  vpc_id      = module.dev_vpc.vpc_id
  peer_vpc_id = module.prod_vpc.vpc_id
  
  requester_vpc_cidr = "10.0.0.0/16"
  peer_vpc_cidr      = "10.1.0.0/16"
  
  requester_private_route_table_ids = module.dev_vpc.private_route_table_ids
  requester_public_route_table_ids  = module.dev_vpc.public_route_table_ids
  peer_private_route_table_ids      = module.prod_vpc.private_route_table_ids
  peer_public_route_table_ids       = module.prod_vpc.public_route_table_ids
  
  enable_security_group_rules   = true
  requester_security_group_id   = module.dev_eks.cluster_security_group_id
  peer_security_group_id        = module.prod_eks.cluster_security_group_id
  
  enable_dns_resolution = true

  depends_on = [
    module.dev_vpc,
    module.prod_vpc,
    module.dev_eks,
    module.prod_eks
  ]
}

 
