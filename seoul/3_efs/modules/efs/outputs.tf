output "file_system_id" {
  description = "EFS 파일 시스템 ID"
  value       = aws_efs_file_system.main.id
}

output "file_system_arn" {
  description = "EFS 파일 시스템 ARN"
  value       = aws_efs_file_system.main.arn
}

output "access_point_id" {
  description = "EFS 액세스 포인트 ID"
  value       = aws_efs_access_point.main.id
}

output "access_point_arn" {
  description = "EFS 액세스 포인트 ARN"
  value       = aws_efs_access_point.main.arn
}

output "mount_target_ids" {
  description = "EFS 마운트 타겟 ID들"
  value       = [aws_efs_mount_target.az_b.id, aws_efs_mount_target.az_c.id]
}

output "dns_name" {
  description = "EFS DNS 이름"
  value       = aws_efs_file_system.main.dns_name
}
