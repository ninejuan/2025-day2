variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "nosql"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "account-table"
}
