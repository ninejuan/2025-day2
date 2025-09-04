variable "project_name" {
  description = "프로젝트 이름"
  type        = string
  default     = "web-cdn"
}

variable "environment" {
  description = "환경 이름"
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
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "사용할 가용 영역 목록"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public 서브넷 CIDR 블록 목록"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "bastion_instance_type" {
  description = "Bastion host 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "AWS Key Pair 이름"
  type        = string
  default     = "web-cdn-bastion-key"
}


variable "drm_token" {
  description = "DRM 토큰 값"
  type        = string
  default     = "drm-cloud"
  sensitive   = true
}

variable "sample_videos" {
  description = "업로드할 샘플 비디오 파일들"
  type        = map(string)
  default     = {}
}
