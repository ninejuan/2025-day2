variable "student_number" {
  description = "학생 번호 (선수 등번호)"
  type        = string
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "환경 이름"
  type        = string
  default     = "efs"
}
