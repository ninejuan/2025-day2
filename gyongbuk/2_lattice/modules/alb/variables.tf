variable "name" {
  description = "Name of the ALB"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ALB"
  type        = list(string)
}

variable "is_internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}
