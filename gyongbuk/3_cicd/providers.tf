terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "dev" {
  name = module.dev_eks.cluster_name
  depends_on = [module.dev_eks]
}

data "aws_eks_cluster_auth" "dev" {
  name = module.dev_eks.cluster_name
  depends_on = [module.dev_eks]
}

data "aws_eks_cluster" "prod" {
  name = module.prod_eks.cluster_name
  depends_on = [module.prod_eks]
}

data "aws_eks_cluster_auth" "prod" {
  name = module.prod_eks.cluster_name
  depends_on = [module.prod_eks]
}

provider "kubernetes" {
  alias                  = "dev"
  host                   = data.aws_eks_cluster.dev.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.dev.token
}

provider "kubernetes" {
  alias                  = "prod"
  host                   = data.aws_eks_cluster.prod.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.prod.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.prod.token
}

provider "helm" {
  alias = "dev"
  kubernetes {
    host                   = data.aws_eks_cluster.dev.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.dev.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.dev.name, "--region", var.aws_region]
    }
  }
}

provider "helm" {
  alias = "prod"
  kubernetes {
    host                   = data.aws_eks_cluster.prod.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.prod.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.prod.name, "--region", var.aws_region]
    }
  }
}

