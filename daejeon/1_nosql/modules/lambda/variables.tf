variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "table_arn" {
  description = "DynamoDB table ARN"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN for Lambda"
  type        = string
}
