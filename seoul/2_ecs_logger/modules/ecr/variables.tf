variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "region" {
  description = "AWS 리전"
  type        = string
}

variable "tags" {
  description = "공통 태그들"
  type        = map(string)
  default     = {}
}
