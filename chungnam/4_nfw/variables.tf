variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "wsc2025"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "nfw-key"
}

variable "egress_vpc_cidr" {
  description = "CIDR block for Egress VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_vpc_cidr" {
  description = "CIDR block for App VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "egress_public_subnets" {
  description = "CIDR blocks for Egress VPC public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "egress_peering_subnets" {
  description = "CIDR blocks for Egress VPC peering subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "egress_firewall_subnets" {
  description = "CIDR blocks for Egress VPC firewall subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "app_private_subnets" {
  description = "CIDR blocks for App VPC private subnets"
  type        = list(string)
  default     = ["172.16.0.0/24", "172.16.1.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}
