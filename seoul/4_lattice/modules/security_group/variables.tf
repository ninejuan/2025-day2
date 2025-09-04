variable "security_group_name" {
  description = "보안 그룹 이름"
  type        = string
}

variable "description" {
  description = "보안 그룹 설명"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ingress_rules" {
  description = "인바운드 규칙 리스트"
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "egress_rules" {
  description = "아웃바운드 규칙 리스트"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
