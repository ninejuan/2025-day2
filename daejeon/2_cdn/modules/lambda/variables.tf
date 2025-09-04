variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "function_name" {
  description = "Lambda 함수 이름"
  type        = string
  default     = "web-drm-function"
}
