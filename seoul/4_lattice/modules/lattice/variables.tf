variable "service_network_name" {
  description = "VPC Lattice 서비스 네트워크 이름"
  type        = string
}

variable "target_group_name" {
  description = "Target Group 이름"
  type        = string
}

variable "target_group_type" {
  description = "Target Group 타입"
  type        = string
  default     = "INSTANCE"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "target_instance_id" {
  description = "Target EC2 인스턴스 ID (i-xxxxxxxxx 형식)"
  type        = string
}

variable "service_name" {
  description = "VPC Lattice 서비스 이름"
  type        = string
}

variable "listener_name" {
  description = "Listener 이름"
  type        = string
}

variable "listener_protocol" {
  description = "Listener 프로토콜"
  type        = string
  default     = "HTTP"
}

variable "listener_port" {
  description = "Listener 포트"
  type        = number
  default     = 80
}

variable "vpc_a_id" {
  description = "VPC A ID"
  type        = string
}

variable "vpc_b_id" {
  description = "VPC B ID"
  type        = string
}

variable "vpc_a_security_group_id" {
  description = "VPC A Security Group ID"
  type        = string
}

variable "vpc_b_security_group_id" {
  description = "VPC B Security Group ID"
  type        = string
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
