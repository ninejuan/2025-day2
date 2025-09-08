variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "working_directory" {
  description = "Working directory for docker commands"
  type        = string
}
