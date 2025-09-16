variable "name_prefix" {
  description = "Name prefix for EC2 instances"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}

variable "target_group_arn" {
  description = "Target group ARN to attach instances"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "user_data_script" {
  description = "User data script filename"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
  default     = ""
}
