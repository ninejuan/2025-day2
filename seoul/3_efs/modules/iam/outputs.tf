output "role_arn" {
  description = "IAM 역할 ARN"
  value       = aws_iam_role.ec2_efs.arn
}

output "role_name" {
  description = "IAM 역할 이름"
  value       = aws_iam_role.ec2_efs.name
}

output "instance_profile_arn" {
  description = "EC2 인스턴스 프로파일 ARN"
  value       = aws_iam_instance_profile.ec2_efs.arn
}

output "instance_profile_name" {
  description = "EC2 인스턴스 프로파일 이름"
  value       = aws_iam_instance_profile.ec2_efs.name
}
