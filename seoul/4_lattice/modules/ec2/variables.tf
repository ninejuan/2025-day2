variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH 키 페어 이름"
  type        = string
}

variable "subnet_id" {
  description = "서브넷 ID"
  type        = string
}

variable "security_group_ids" {
  description = "보안 그룹 ID 리스트"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM 인스턴스 프로필 이름"
  type        = string
  default     = ""
}

variable "user_data_template" {
  description = "사용자 데이터 템플릿 파일 경로"
  type        = string
  default     = ""
}

variable "user_data_vars" {
  description = "사용자 데이터 템플릿 변수"
  type        = map(any)
  default     = {}
}

variable "instance_name" {
  description = "인스턴스 이름"
  type        = string
}

variable "create_eip" {
  description = "Elastic IP 생성 여부"
  type        = bool
  default     = false
}

variable "tags" {
  description = "리소스 태그"
  type        = map(string)
  default     = {}
}
