output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.wsi_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.wsi_alb.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.wsi_tg.arn
}

output "security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.wsi_alb_sg.id
}

output "alb_name" {
  description = "Name of the Application Load Balancer"
  value       = aws_lb.wsi_alb.name
}

output "alb_full_name" {
  description = "Full name of the Application Load Balancer for CloudWatch metrics"
  value       = "${aws_lb.wsi_alb.arn_suffix}"
}
