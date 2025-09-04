output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.conflict_resolver.function_name
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.conflict_resolver.arn
}

output "function_invoke_arn" {
  description = "Lambda function invoke ARN"
  value       = aws_lambda_function.conflict_resolver.invoke_arn
}
