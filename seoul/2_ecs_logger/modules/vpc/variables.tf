variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록들"
  type        = list(string)
}

variable "availability_zones" {
  description = "가용영역들"
  type        = list(string)
}

variable "app_port" {
  description = "애플리케이션 포트"
  type        = number
}

variable "tags" {
  description = "공통 태그들"
  type        = map(string)
  default     = {}
}
