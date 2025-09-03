variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public 서브넷 CIDR 블록들"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private 서브넷 CIDR 블록들"
  type        = list(string)
}

variable "availability_zones" {
  description = "가용영역들"
  type        = list(string)
}
