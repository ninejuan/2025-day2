variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
}

variable "nat_names" {
  description = "List of NAT Gateway names"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet configurations"
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "List of private subnet configurations"
  type = list(object({
    name    = string
    cidr    = string
    az      = string
    rt_name = string
  }))
}

variable "public_rt_name" {
  description = "Name of the public route table"
  type        = string
}
