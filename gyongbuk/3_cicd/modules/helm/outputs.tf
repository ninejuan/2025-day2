output "argocd_release_name" {
  description = "ArgoCD release name in dev"
  value       = try(helm_release.argocd[0].name, null)
}

output "argo_rollouts_dev_release" {
  description = "Argo Rollouts release name in dev"
  value       = try(helm_release.argo_rollouts_dev[0].name, null)
}

output "argo_rollouts_prod_release" {
  description = "Argo Rollouts release name in prod"
  value       = try(helm_release.argo_rollouts_prod[0].name, null)
}

output "alb_controller_dev_release" {
  description = "ALB Controller release name in dev"
  value       = try(helm_release.alb_controller_dev[0].name, null)
}

output "alb_controller_prod_release" {
  description = "ALB Controller release name in prod"
  value       = try(helm_release.alb_controller_prod[0].name, null)
}
