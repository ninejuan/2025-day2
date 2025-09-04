variable "role_name" {
  description = "IAM 역할 이름"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM 인스턴스 프로필 이름"
  type        = string
}

variable "managed_policy_arns" {
  description = "관리형 정책 ARN 리스트"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "인라인 정책 맵"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
