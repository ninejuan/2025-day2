variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "instance_type" {
  description = "Bastion Host 인스턴스 타입"
  type        = string
}

variable "security_group_ids" {
  description = "보안 그룹 ID들"
  type        = list(string)
}

variable "subnet_id" {
  description = "서브넷 ID"
  type        = string
}

variable "user_data" {
  description = "Bastion Host 사용자 데이터 스크립트"
  type        = string
}

variable "tags" {
  description = "공통 태그들"
  type        = map(string)
  default     = {}
}
