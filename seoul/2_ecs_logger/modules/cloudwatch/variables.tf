variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "cpu_threshold" {
  description = "CPU 사용률 임계값 (%)"
  type        = number
}

variable "cluster_name" {
  description = "ECS 클러스터 이름"
  type        = string
}

variable "service_name" {
  description = "ECS 서비스 이름"
  type        = string
}

variable "tags" {
  description = "공통 태그들"
  type        = map(string)
  default     = {}
}
