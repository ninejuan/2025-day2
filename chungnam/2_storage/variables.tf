variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "bucket_prefix" {
  type    = string
  default = "wsc2025-sensitive"
}

variable "lambda_function_name" {
  type    = string
  default = "wsc2025-masking-start"
}

variable "macie_job_name" {
  type    = string
  default = "wsc2025-sensor-job"
}

variable "macie_enable" {
  type        = bool
  description = "Enable Macie account via Terraform. Set false if already enabled (e.g., training account)."
  default     = true
}
