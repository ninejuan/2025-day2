variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public 서브넷 ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
}

variable "key_name" {
  description = "EC2 키페어 이름"
  type        = string
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
}
