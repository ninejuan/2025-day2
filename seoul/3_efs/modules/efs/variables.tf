variable "file_system_name" {
  description = "EFS 파일 시스템 이름"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS 키 ARN"
  type        = string
}

variable "subnet_ids" {
  description = "EFS 마운트 타겟을 생성할 서브넷 ID들"
  type        = list(string)
}

variable "security_group_ids" {
  description = "EFS 보안 그룹 ID들"
  type        = list(string)
}

variable "access_point_name" {
  description = "EFS 액세스 포인트 이름"
  type        = string
}

variable "root_directory_path" {
  description = "액세스 포인트 루트 디렉토리 경로"
  type        = string
}

variable "app_instance_ips" {
  description = "App 인스턴스 IP 주소들"
  type        = list(string)
}

variable "bastion_ip" {
  description = "Bastion 호스트 IP 주소"
  type        = string
}

variable "student_number" {
  description = "학생 번호 (선수 등번호)"
  type        = string
}

variable "mount_target_ips" {
  description = "EFS 마운트 타겟 IP 주소들"
  type        = list(string)
  default     = ["10.128.128.111", "10.128.144.111"]
}

variable "iam_role_arn" {
  description = "IAM 역할 ARN"
  type        = string
}
