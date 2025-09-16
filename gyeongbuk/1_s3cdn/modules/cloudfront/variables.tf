variable "mrap_alias" {
  description = "Alias of the Multi-Region Access Point"
  type        = string
}

variable "mrap_domain" {
  description = "Domain of the Multi-Region Access Point"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "kr_bucket_domain" {
  description = "Regional domain of the KR S3 bucket"
  type        = string
}

variable "us_bucket_domain" {
  description = "Regional domain of the US S3 bucket"
  type        = string
}
