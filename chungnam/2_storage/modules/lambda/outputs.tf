output "function_name" {
  value = aws_lambda_function.masking_function.function_name
}

output "function_arn" {
  value = aws_lambda_function.masking_function.arn
}

output "permission_dependency" {
  value = aws_lambda_permission.allow_bucket
}
