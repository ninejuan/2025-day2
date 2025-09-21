variable "prefix" {}

variable "bucket_name" {}

variable "account_id" {}

variable "enable_macie" {
  type        = bool
  description = "If true, enable Macie account via aws_macie2_account. Set false if Macie is already enabled."
  default     = true
}