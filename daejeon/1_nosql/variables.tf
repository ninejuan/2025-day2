variable "aws_region" {
  description = "AWS region for primary resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "account-table"
}

variable "lambda_function_name" {
  description = "Lambda function name for conflict resolution"
  type        = string
  default     = "account-conflict-resolver"
}

variable "ec2_instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "account-app-ec2"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
