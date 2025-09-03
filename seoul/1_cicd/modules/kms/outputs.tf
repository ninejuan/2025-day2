output "kms_key_id" {
  description = "KMS 키 ID"
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "KMS 키 ARN"
  value       = aws_kms_key.main.arn
}

output "kms_alias_name" {
  description = "KMS 별칭 이름"
  value       = aws_kms_alias.main.name
}
