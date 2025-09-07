variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "wsc2025"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "waf-key"
}

variable "app_instance_type" {
  description = "Instance type for app server"
  type        = string
  default     = "t3.small"
}

variable "bastion_instance_type" {
  description = "Instance type for bastion"
  type        = string
  default     = "t3.micro"
}
