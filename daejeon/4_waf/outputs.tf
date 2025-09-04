output "xxe_server_public_ip" {
  description = "Public IP of the XXE server"
  value       = module.ec2.public_ip
}

output "xxe_server_private_ip" {
  description = "Private IP of the XXE server"
  value       = module.ec2.private_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "waf_arn" {
  description = "ARN of the WAF Web ACL"
  value       = module.waf.waf_arn
}

output "waf_name" {
  description = "Name of the WAF Web ACL"
  value       = module.waf.waf_name
}

output "ssh_connection_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i waf-key ec2-user@${module.bastion.bastion_public_ip}"
}

output "application_url" {
  description = "URL to access the XXE application"
  value       = "http://${module.alb.alb_dns_name}"
}
