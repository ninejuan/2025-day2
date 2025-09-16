variable "mrap_name" {
  description = "Name of the Multi-Region Access Point"
  type        = string
}

variable "kr_bucket_name" {
  description = "Name of the Korea S3 bucket"
  type        = string
}

variable "us_bucket_name" {
  description = "Name of the US S3 bucket"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
