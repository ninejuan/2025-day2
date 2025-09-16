variable "aws_region_kr" {
  description = "AWS region for Korea resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_region_us" {
  description = "AWS region for US resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "s3cdn"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "allowed_countries" {
  description = "List of allowed countries for CloudFront"
  type        = list(string)
  default     = ["KR", "US"]
}

variable "blocked_user_agents" {
  description = "List of blocked user agent patterns"
  type        = list(string)
  default     = ["bot", "crawler", "spider"]
}
