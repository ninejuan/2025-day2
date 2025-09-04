variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public 서브넷 ID"
  type        = string
}

variable "key_pair_name" {
  description = "AWS Key Pair 이름"
  type        = string
}

variable "public_key" {
  description = "SSH 공개키 내용"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "user_data" {
  description = "User data 스크립트"
  type        = string
  default     = ""
}
