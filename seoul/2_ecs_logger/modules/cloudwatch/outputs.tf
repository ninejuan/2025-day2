output "cloudwatch_alarm_name" {
  description = "CloudWatch 경보 이름"
  value       = aws_cloudwatch_metric_alarm.cpu.alarm_name
}

output "cloudwatch_alarm_arn" {
  description = "CloudWatch 경보 ARN"
  value       = aws_cloudwatch_metric_alarm.cpu.arn
}
