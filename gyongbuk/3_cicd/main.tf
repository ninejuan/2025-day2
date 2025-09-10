module "dev_vpc" {
  source = "./modules/vpc"

  vpc_name               = "dev-vpc"
  vpc_cidr              = "10.0.0.0/16"
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "prod_vpc" {
  source = "./modules/vpc"

  vpc_name               = "prod-vpc"
  vpc_cidr              = "10.1.0.0/16"
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs  = ["10.1.11.0/24", "10.1.12.0/24"]
}

module "dev_eks" {
  source = "./modules/eks"

  cluster_name        = "dev-cluster"
  vpc_id              = module.dev_vpc.vpc_id
  subnet_ids          = concat(module.dev_vpc.public_subnet_ids, module.dev_vpc.private_subnet_ids)
  private_subnet_ids  = module.dev_vpc.private_subnet_ids
}

module "prod_eks" {
  source = "./modules/eks"

  cluster_name        = "prod-cluster"
  vpc_id              = module.prod_vpc.vpc_id
  subnet_ids          = concat(module.prod_vpc.public_subnet_ids, module.prod_vpc.private_subnet_ids)
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
    module.prod_eks
  ]
}

module "helm" {
  source = "./modules/helm"

  providers = {
    helm.dev  = helm.dev
    helm.prod = helm.prod
    kubernetes.dev  = kubernetes.dev
    kubernetes.prod = kubernetes.prod
  }

  dev_cluster_name  = module.dev_eks.cluster_name
  prod_cluster_name = module.prod_eks.cluster_name
  aws_region        = var.aws_region
  github_token      = var.github_token

  enable_argocd_dev    = true
  enable_rollouts_dev  = true
  enable_rollouts_prod = true
  enable_alb_dev       = true
  enable_alb_prod      = true

  depends_on = [
    module.kubernetes
  ]
}


