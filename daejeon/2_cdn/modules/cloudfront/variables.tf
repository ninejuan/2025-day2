variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "function_name" {
  description = "CloudFront Function 이름"
  type        = string
  default     = "web-cdn-function"
}

variable "distribution_name" {
  description = "CloudFront 배포 이름"
  type        = string
  default     = "web-cdn"
}

variable "s3_bucket_name" {
  description = "S3 버킷 이름"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "S3 버킷 도메인 이름"
  type        = string
}


variable "lambda_edge_arn" {
  description = "Lambda@Edge 함수 ARN"
  type        = string
}
