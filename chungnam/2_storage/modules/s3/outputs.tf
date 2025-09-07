output "bucket_name" {
  value = aws_s3_bucket.sensitive_data.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.sensitive_data.arn
}

output "bucket_suffix" {
  value = random_string.bucket_suffix.result
}
