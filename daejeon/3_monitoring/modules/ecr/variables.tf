variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "app_files_path" {
  description = "Path to the app-files directory"
  type        = string
}
