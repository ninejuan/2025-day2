variable "vpc_name" {
  description = "VPC 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public 서브넷 CIDR 블록"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private 서브넷 CIDR 블록"
  type        = string
}

variable "availability_zone" {
  description = "가용구역"
  type        = string
}

variable "subnet_name_prefix" {
  description = "서브넷 이름 접두사 (예: va, vb)"
  type        = string
  default     = ""
}

variable "availability_zone_suffix" {
  description = "가용구역 접미사 (예: a, b)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
