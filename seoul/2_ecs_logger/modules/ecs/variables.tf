variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "app_image" {
  description = "애플리케이션 Docker 이미지 (사용하지 않음, ecr_image_url 사용)"
  type        = string
}

variable "ecr_image_url" {
  description = "ECR 이미지 URL"
  type        = string
}

variable "app_port" {
  description = "애플리케이션 포트"
  type        = number
}

variable "app_count" {
  description = "애플리케이션 인스턴스 수"
  type        = number
}

variable "cpu" {
  description = "ECS Task CPU 유닛"
  type        = number
}

variable "memory" {
  description = "ECS Task 메모리 (MB)"
  type        = number
}

variable "execution_role_arn" {
  description = "ECS Task Execution 역할 ARN"
  type        = string
}

variable "security_group_ids" {
  description = "보안 그룹 ID들"
  type        = list(string)
}

variable "ecs_tasks_security_group_id" {
  description = "ECS Tasks 보안 그룹 ID"
  type        = string
}

variable "subnet_ids" {
  description = "서브넷 ID들"
  type        = list(string)
}

variable "region" {
  description = "AWS 리전"
  type        = string
}

variable "ecr_image_ready" {
  description = "ECR 이미지 푸시 완료 신호"
  type        = any
}

variable "tags" {
  description = "공통 태그들"
  type        = map(string)
  default     = {}
}
