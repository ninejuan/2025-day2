variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "skills-app-table"
}

variable "hash_key" {
  description = "Hash key for the DynamoDB table"
  type        = string
  default     = "UserId"
}
