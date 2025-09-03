output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public 서브넷 ID들"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private 서브넷 ID들"
  value       = module.vpc.private_subnet_ids
}

output "bastion_public_ip" {
  description = "Bastion 호스트 공인 IP"
  value       = module.ec2.bastion_public_ip
}

output "app_instance_ids" {
  description = "App 인스턴스 ID들"
  value       = module.ec2.app_instance_ids
}

output "efs_file_system_id" {
  description = "EFS 파일 시스템 ID"
  value       = module.efs.file_system_id
}

output "efs_access_point_id" {
  description = "EFS 액세스 포인트 ID"
  value       = module.efs.access_point_id
}

output "kms_key_arn" {
  description = "KMS 키 ARN"
  value       = module.kms.key_arn
}

output "iam_role_arn" {
  description = "IAM 역할 ARN"
  value       = module.iam.role_arn
}
