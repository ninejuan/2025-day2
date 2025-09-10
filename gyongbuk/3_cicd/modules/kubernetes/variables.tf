variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "day2-product"
}

variable "dev_oidc_issuer" {
  description = "Dev EKS cluster OIDC issuer URL"
  type        = string
}

variable "prod_oidc_issuer" {
  description = "Prod EKS cluster OIDC issuer URL"
  type        = string
}
