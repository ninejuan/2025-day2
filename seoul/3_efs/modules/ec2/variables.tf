variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public 서브넷 ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private 서브넷 ID들"
  type        = map(string)
}

variable "bastion_ip" {
  description = "Bastion 호스트 Private IP"
  type        = string
}

variable "app1_ip" {
  description = "App 1 Private IP"
  type        = string
}

variable "app2_ip" {
  description = "App 2 Private IP"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM 인스턴스 프로파일 이름"
  type        = string
}

variable "student_number" {
  description = "학생 번호 (선수 등번호)"
  type        = string
}
