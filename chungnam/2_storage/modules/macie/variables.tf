variable "job_name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "custom_data_identifier_ids" {
  type    = list(string)
  default = []
}
