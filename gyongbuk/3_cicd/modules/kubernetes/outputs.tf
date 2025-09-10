output "github_actions_role_arn" {
  description = "The ARN of the GitHub Actions role"
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "aws_load_balancer_controller_dev_role_arn" {
  description = "The ARN of the AWS Load Balancer Controller role for dev"
  value       = aws_iam_role.aws_load_balancer_controller_dev.arn
}

output "aws_load_balancer_controller_prod_role_arn" {
  description = "The ARN of the AWS Load Balancer Controller role for prod"
  value       = aws_iam_role.aws_load_balancer_controller_prod.arn
}
