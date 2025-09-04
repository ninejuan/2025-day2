output "bucket_id" {
  description = "S3 버킷 ID"
  value       = aws_s3_bucket.drm_bucket.id
}

output "bucket_arn" {
  description = "S3 버킷 ARN"
  value       = aws_s3_bucket.drm_bucket.arn
}

output "bucket_domain_name" {
  description = "S3 버킷 도메인 이름"
  value       = aws_s3_bucket.drm_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "S3 버킷 지역 도메인 이름"
  value       = aws_s3_bucket.drm_bucket.bucket_regional_domain_name
}

output "bucket_name" {
  description = "S3 버킷 이름"
  value       = aws_s3_bucket.drm_bucket.bucket
}
