variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ID of the ECS security group"
  type        = string
}

variable "ecr_app_repository_url" {
  description = "URL of the app ECR repository"
  type        = string
}

variable "ecr_firelens_repository_url" {
  description = "URL of the firelens ECR repository"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "app_image_pushed" {
  description = "Trigger for when app image is pushed"
  type        = string
}

variable "firelens_image_pushed" {
  description = "Trigger for when firelens image is pushed"
  type        = string
}
