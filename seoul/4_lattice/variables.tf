variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "환경 이름"
  type        = string
  default     = "lattice"
}
