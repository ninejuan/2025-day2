variable "key_alias" {
  description = "KMS 키 별칭"
  type        = string
}

variable "iam_role_arn" {
  description = "IAM 역할 ARN"
  type        = string
  default     = null
}
