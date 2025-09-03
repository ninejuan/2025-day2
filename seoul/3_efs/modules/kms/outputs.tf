output "key_id" {
  description = "KMS 키 ID"
  value       = aws_kms_key.main.id
}

output "key_arn" {
  description = "KMS 키 ARN"
  value       = aws_kms_key.main.arn
}

output "key_alias" {
  description = "KMS 키 별칭"
  value       = aws_kms_alias.main.name
}
