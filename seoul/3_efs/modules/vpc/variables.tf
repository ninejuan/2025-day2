variable "vpc_name" {
  description = "VPC 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "public_subnets" {
  description = "Public 서브넷 설정 (이름: CIDR)"
  type        = map(string)
}

variable "private_subnets" {
  description = "Private 서브넷 설정 (이름: CIDR)"
  type        = map(string)
}
