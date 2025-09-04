
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR 블록"
  value       = module.vpc.vpc_cidr_block
}

output "bastion_public_ip" {
  description = "Bastion host 공개 IP"
  value       = module.bastion.bastion_public_ip
}

output "bastion_private_ip" {
  description = "Bastion host 사설 IP"
  value       = module.bastion.bastion_private_ip
}

output "s3_bucket_name" {
  description = "S3 버킷 이름"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 버킷 ARN"
  value       = module.s3.bucket_arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront 도메인 이름"
  value       = module.cloudfront.cloudfront_domain_name
}

output "cloudfront_url" {
  description = "CloudFront URL"
  value       = "https://${module.cloudfront.cloudfront_domain_name}"
}

output "lambda_function_arn" {
  description = "Lambda 함수 ARN"
  value       = module.lambda.lambda_function_arn
}

output "test_instructions" {
  description = "DRM 테스트 방법"
  value = <<-EOT
    DRM 보호된 미디어 테스트 방법:
    
    1. 유효한 DRM 토큰으로 요청:
       https://${module.cloudfront.cloudfront_domain_name}/media/sample.mp4?drm_token=drm-cloud
    
    2. DRM 토큰 없이 요청 (403 에러 예상):
       https://${module.cloudfront.cloudfront_domain_name}/media/sample.mp4
    
    3. 잘못된 DRM 토큰으로 요청 (403 에러 예상):
       https://${module.cloudfront.cloudfront_domain_name}/media/sample.mp4?drm_token=invalid-token
    
    Bastion Host 접속:
    ssh -i cdn-key ec2-user@${module.bastion.bastion_public_ip}
  EOT
}
