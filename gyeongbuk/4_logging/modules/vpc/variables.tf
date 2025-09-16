variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for private subnet A"
  type        = string
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for private subnet B"
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet B"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}
