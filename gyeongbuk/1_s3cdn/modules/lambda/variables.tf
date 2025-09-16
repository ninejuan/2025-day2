variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "role_name" {
  description = "Name of the IAM role for Lambda"
  type        = string
}

variable "distribution_id" {
  description = "CloudFront distribution ID"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
