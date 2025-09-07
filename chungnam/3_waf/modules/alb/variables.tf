variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ALB"
  type        = list(string)
}

variable "target_instance_id" {
  description = "Target instance ID"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}
