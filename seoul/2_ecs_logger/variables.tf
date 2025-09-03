variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "wsi"
}

variable "environment" {
  description = "환경"
  type        = string
  default     = "production"
}

variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR 블록들"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "availability_zones" {
  description = "가용영역들"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "app_port" {
  description = "애플리케이션 포트"
  type        = number
  default     = 80
}

variable "app_image" {
  description = "애플리케이션 Docker 이미지"
  type        = string
  default     = "wsi-python-app"
}

variable "app_count" {
  description = "애플리케이션 인스턴스 수"
  type        = number
  default     = 2
}

variable "cpu" {
  description = "ECS Task CPU 유닛"
  type        = number
  default     = 256
}

variable "memory" {
  description = "ECS Task 메모리 (MB)"
  type        = number
  default     = 512
}

variable "cpu_threshold" {
  description = "CPU 사용률 임계값"
  type        = number
  default     = 80
}

variable "bastion_instance_type" {
  description = "Bastion Host 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}
