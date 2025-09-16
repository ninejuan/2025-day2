output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "kr_bucket_name" {
  description = "Name of the Korea S3 bucket"
  value       = module.s3_kr.bucket_name
}

output "us_bucket_name" {
  description = "Name of the US S3 bucket"
  value       = module.s3_us.bucket_name
}

output "mrap_alias" {
  description = "Alias of the Multi-Region Access Point"
  value       = module.mrap.alias
}

output "mrap_domain" {
  description = "Domain of the Multi-Region Access Point"
  value       = module.mrap.domain
}

output "mrap_dummy_domain" {
  description = "Domain of the dummy Multi-Region Access Point"
  value       = module.mrap.dummy_domain
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = module.bastion.private_ip
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.cloudfront.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_url" {
  description = "URL of the CloudFront distribution"
  value       = "https://${module.cloudfront.domain_name}"
}
