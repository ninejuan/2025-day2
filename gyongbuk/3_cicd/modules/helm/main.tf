terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
      configuration_aliases = [helm.dev, helm.prod]
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
      configuration_aliases = [kubernetes.dev, kubernetes.prod]
    }
  }
}

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
          type = "ClusterIP"
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

  depends_on = [
    helm_release.alb_controller_dev
  ]

  timeout     = 600
  wait        = false
  atomic      = false
  max_history = 2

}

resource "helm_release" "cert_manager_dev" {
  count      = var.enable_cert_manager_dev ? 1 : 0
  provider   = helm.dev
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = var.cert_manager_chart_version

  create_namespace = true

  values = [
    yamlencode({
      installCRDs = true
    })
  ]

  depends_on = [
    helm_release.alb_controller_dev
  ]

  timeout     = 600
  wait        = false
  atomic      = false
  max_history = 2
}

resource "helm_release" "cert_manager_prod" {
  count      = var.enable_cert_manager_prod ? 1 : 0
  provider   = helm.prod
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = var.cert_manager_chart_version

  create_namespace = true

  values = [
    yamlencode({
      installCRDs = true
    })
  ]

  depends_on = [
    helm_release.alb_controller_prod
  ]

  timeout     = 600
  wait        = false
  atomic      = false
  max_history = 2
}

resource "kubernetes_namespace" "arc_dev" {
  count    = var.enable_arc_dev ? 1 : 0
  provider = kubernetes.dev
  metadata {
    name = "actions-runner-system"
  }
}

resource "kubernetes_secret" "arc_token_dev" {
  count    = var.enable_arc_dev ? 1 : 0
  provider = kubernetes.dev
  metadata {
    name      = "controller-manager"
    namespace = "actions-runner-system"
  }
  type = "Opaque"
  data = {
    github_token = base64encode(var.github_token)
  }
  depends_on = [kubernetes_namespace.arc_dev]
}

resource "kubernetes_namespace" "arc_prod" {
  count    = var.enable_arc_prod ? 1 : 0
  provider = kubernetes.prod
  metadata {
    name = "actions-runner-system"
  }
}

resource "kubernetes_secret" "arc_token_prod" {
  count    = var.enable_arc_prod ? 1 : 0
  provider = kubernetes.prod
  metadata {
    name      = "controller-manager"
    namespace = "actions-runner-system"
  }
  type = "Opaque"
  data = {
    github_token = base64encode(var.github_token)
  }
  depends_on = [kubernetes_namespace.arc_prod]
}

resource "helm_release" "arc_dev" {
  count      = var.enable_arc_dev ? 1 : 0
  provider   = helm.dev
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  namespace  = "actions-runner-system"
  version    = var.arc_chart_version

  create_namespace = false

  values = [
    yamlencode({
      authSecret = {
        name = "controller-manager"
        key  = "github_token"
      }
      scope = {
        singleNamespace = false
      }
    })
  ]

  timeout     = 600
  wait        = false
  atomic      = false
  max_history = 2

  depends_on = [
    helm_release.cert_manager_dev,
    kubernetes_secret.arc_token_dev
  ]
}

resource "helm_release" "arc_prod" {
  count      = var.enable_arc_prod ? 1 : 0
  provider   = helm.prod
  name       = "actions-runner-controller"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  namespace  = "actions-runner-system"
  version    = var.arc_chart_version

  create_namespace = false

  values = [
    yamlencode({
      authSecret = {
        name = "controller-manager"
        key  = "github_token"
      }
      scope = {
        singleNamespace = false
      }
    })
  ]

  timeout     = 600
  wait        = false
  atomic      = false
  max_history = 2

  depends_on = [
    helm_release.cert_manager_prod,
    kubernetes_secret.arc_token_prod
  ]
}

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
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [
    helm_release.alb_controller_dev
  ]

  timeout     = 600
  wait        = false
  atomic      = false
  max_history = 2
}

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

  depends_on = [
    helm_release.alb_controller_prod
  ]

  timeout          = 600
  wait             = false
  atomic           = false
  cleanup_on_fail  = true
  force_update     = true
  replace          = true
  max_history = 2
}

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
    name  = "vpcId"
    value = var.dev_vpc_id
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
  wait       = false
  atomic     = false
  max_history = 2

}

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
    name  = "vpcId"
    value = var.prod_vpc_id
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

  timeout          = 600
  wait             = false
  atomic           = false
  cleanup_on_fail  = true
  force_update     = true
  replace          = true
  max_history = 2

}
