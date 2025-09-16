variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "lattice-key"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
