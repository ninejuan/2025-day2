output "alb_controller_role_arn" {
  description = "ARN of the ALB controller IAM role"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "alb_controller_policy_arn" {
  description = "ARN of the ALB controller IAM policy"
  value       = aws_iam_policy.aws_load_balancer_controller.arn
}
