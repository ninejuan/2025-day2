terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
      configuration_aliases = [helm.dev, helm.prod]
    }
  }
}

# Argo CD - dev only
resource "helm_release" "argocd" {
  count      = var.enable_argocd_dev ? 1 : 0
  provider   = helm.dev
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = var.argocd_chart_version

  create_namespace = true

  values = [
    yamlencode({
      crds = {
        install = true
      }
      server = {
        service = {
          type = "LoadBalancer"
        }
        extraArgs = ["--insecure"]
      }
      global = {
        image = {
          tag = var.argocd_image_tag
        }
      }
    })
  ]

  timeout     = 600
  wait        = false
  atomic      = false
  max_history = 2
}

# Argo Rollouts - dev
resource "helm_release" "argo_rollouts_dev" {
  count      = var.enable_rollouts_dev ? 1 : 0
  provider   = helm.dev
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = "argo-rollouts"
  version    = var.argo_rollouts_chart_version

  create_namespace = true

  values = [
    yamlencode({
      installCRDs = true
      dashboard = {
        enabled = true
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]

  timeout     = 600
  wait        = false
  atomic      = false
  max_history = 2
}

# Argo Rollouts - prod
resource "helm_release" "argo_rollouts_prod" {
  count      = var.enable_rollouts_prod ? 1 : 0
  provider   = helm.prod
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = "argo-rollouts"
  version    = var.argo_rollouts_chart_version

  create_namespace = true

  values = [
    yamlencode({
      dashboard = {
        enabled = false
      }
    })
  ]

  timeout    = 600
  wait       = true
  atomic     = true
  max_history = 2
}

# AWS Load Balancer Controller - dev
resource "helm_release" "alb_controller_dev" {
  count      = var.enable_alb_dev ? 1 : 0
  provider   = helm.dev
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.alb_controller_chart_version

  set {
    name  = "clusterName"
    value = var.dev_cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  timeout    = 600
  wait       = true
  atomic     = true
  max_history = 2
}

# AWS Load Balancer Controller - prod
resource "helm_release" "alb_controller_prod" {
  count      = var.enable_alb_prod ? 1 : 0
  provider   = helm.prod
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = var.alb_controller_chart_version

  set {
    name  = "clusterName"
    value = var.prod_cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  timeout    = 600
  wait       = true
  atomic     = true
  max_history = 2
}
