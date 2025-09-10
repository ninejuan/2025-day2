variable "enable_argocd_dev" {
  type        = bool
  description = "Install Argo CD in dev cluster"
  default     = true
}

variable "enable_rollouts_dev" {
  type        = bool
  description = "Install Argo Rollouts in dev cluster"
  default     = true
}

variable "enable_rollouts_prod" {
  type        = bool
  description = "Install Argo Rollouts in prod cluster"
  default     = true
}

variable "enable_alb_dev" {
  type        = bool
  description = "Install AWS Load Balancer Controller in dev cluster"
  default     = true
}

variable "enable_alb_prod" {
  type        = bool
  description = "Install AWS Load Balancer Controller in prod cluster"
  default     = true
}

variable "argocd_chart_version" {
  type        = string
  description = "Argo CD chart version"
  default     = "5.46.8"
}

variable "argocd_image_tag" {
  type        = string
  description = "Argo CD image tag"
  default     = "v2.8.4"
}

variable "argo_rollouts_chart_version" {
  type        = string
  description = "Argo Rollouts chart version"
  default     = "2.32.0"
}

variable "alb_controller_chart_version" {
  type        = string
  description = "AWS Load Balancer Controller chart version"
  default     = "1.6.2"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "dev_cluster_name" {
  type        = string
  description = "Dev EKS cluster name"
}

variable "prod_cluster_name" {
  type        = string
  description = "Prod EKS cluster name"
}

variable "enable_cert_manager_dev" {
  type        = bool
  description = "Install cert-manager in dev"
  default     = true
}

variable "enable_cert_manager_prod" {
  type        = bool
  description = "Install cert-manager in prod"
  default     = true
}

variable "cert_manager_chart_version" {
  type        = string
  description = "cert-manager chart version"
  default     = "v1.13.2"
}

variable "enable_arc_dev" {
  type        = bool
  description = "Install Actions Runner Controller in dev"
  default     = true
}

variable "enable_arc_prod" {
  type        = bool
  description = "Install Actions Runner Controller in prod"
  default     = true
}

variable "arc_chart_version" {
  type        = string
  description = "Actions Runner Controller chart version"
  default     = "0.23.3"
}

variable "github_token" {
  type        = string
  description = "GitHub token for ARC authSecret"
  sensitive   = true
}

variable "dev_vpc_id" {
  type        = string
  description = "Dev VPC ID"
}

variable "prod_vpc_id" {
  type        = string
  description = "Prod VPC ID"
}
