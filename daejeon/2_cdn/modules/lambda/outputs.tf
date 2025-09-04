output "lambda_function_arn" {
  description = "Lambda 함수 ARN"
  value       = aws_lambda_function.drm_function.arn
}

output "lambda_function_version_arn" {
  description = "Lambda 함수 버전 ARN (Lambda@Edge용)"
  value       = aws_lambda_function.drm_function_version.qualified_arn
}

output "lambda_function_name" {
  description = "Lambda 함수 이름"
  value       = aws_lambda_function.drm_function.function_name
}

output "lambda_role_arn" {
  description = "Lambda 실행 역할 ARN"
  value       = aws_iam_role.lambda_edge_role.arn
}
