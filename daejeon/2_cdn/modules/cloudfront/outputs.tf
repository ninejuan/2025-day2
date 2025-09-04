output "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  value       = aws_cloudfront_distribution.drm_distribution.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront 배포 ARN"
  value       = aws_cloudfront_distribution.drm_distribution.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront 도메인 이름"
  value       = aws_cloudfront_distribution.drm_distribution.domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront 호스팅 영역 ID"
  value       = aws_cloudfront_distribution.drm_distribution.hosted_zone_id
}

output "cloudfront_function_arn" {
  description = "CloudFront Function ARN"
  value       = aws_cloudfront_function.drm_function.arn
}

output "origin_access_identity_id" {
  description = "Origin Access Identity ID"
  value       = aws_cloudfront_origin_access_identity.drm_oai.id
}

output "origin_access_identity_iam_arn" {
  description = "Origin Access Identity IAM ARN"
  value       = aws_cloudfront_origin_access_identity.drm_oai.iam_arn
}
