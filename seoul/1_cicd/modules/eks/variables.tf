variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private 서브넷 ID들"
  type        = list(string)
}

variable "kms_key_id" {
  description = "KMS 키 ARN"
  type        = string
}
