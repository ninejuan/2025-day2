output "waf_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.xxe_waf.arn
}

output "waf_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.xxe_waf.id
}

output "waf_name" {
  description = "Name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.xxe_waf.name
}
