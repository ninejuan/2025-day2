output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.main.arn
}

output "table_stream_arn" {
  description = "DynamoDB table stream ARN"
  value       = aws_dynamodb_table.main.stream_arn
}

output "lambda_role_arn" {
  description = "IAM role ARN for Lambda"
  value       = aws_iam_role.lambda_dynamodb_role.arn
}
