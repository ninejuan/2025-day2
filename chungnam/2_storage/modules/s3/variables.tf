variable "bucket_prefix" {
  type = string
}

variable "lambda_function_arn" {
  type = string
}

variable "lambda_permission_dependency" {
  type = any
}
