output "arn" {
  description = "ARN of the Multi-Region Access Point"
  value       = aws_s3control_multi_region_access_point.main.arn
}

output "alias" {
  description = "Alias of the Multi-Region Access Point"
  value       = aws_s3control_multi_region_access_point.main.alias
}

output "domain" {
  description = "Domain of the Multi-Region Access Point"
  value       = aws_s3control_multi_region_access_point.main.domain_name
}

output "dummy_domain" {
  description = "Domain of the dummy MRAP"
  value       = aws_s3control_multi_region_access_point.dummy.domain_name
}
