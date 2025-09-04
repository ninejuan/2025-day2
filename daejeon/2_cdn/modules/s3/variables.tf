variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront 배포 ARN"
  type        = string
}

variable "sample_videos" {
  description = "업로드할 샘플 비디오 파일들"
  type        = map(string)
  default     = {}
}
