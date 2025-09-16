variable "name" {
  description = "Name of the bastion host"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for bastion"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "dev_cluster_name" {
  description = "Dev EKS cluster name"
  type        = string
}

variable "prod_cluster_name" {
  description = "Prod EKS cluster name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
