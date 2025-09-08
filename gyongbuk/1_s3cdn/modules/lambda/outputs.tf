output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.lambda.arn
}
