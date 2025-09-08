variable "vpc_id" {
  description = "VPC ID for bastion host"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for bastion host"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}
