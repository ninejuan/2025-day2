variable "consumer_vpc_id" {
  description = "Consumer VPC ID"
  type        = string
}

variable "service_vpc_id" {
  description = "Service VPC ID"
  type        = string
}

variable "service_subnet_ids" {
  description = "Service subnet IDs for target group"
  type        = list(string)
}

variable "app_alb_arn" {
  description = "ARN of the application ALB"
  type        = string
}
