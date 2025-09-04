variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "waf-xxe"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
