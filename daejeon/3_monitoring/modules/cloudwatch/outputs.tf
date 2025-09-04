output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://ap-southeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-1#dashboards:name=${var.name_prefix}-dashboard"
}

output "query_definition_name" {
  description = "Name of the CloudWatch query definition"
  value       = aws_cloudwatch_query_definition.wsi_query.name
}
