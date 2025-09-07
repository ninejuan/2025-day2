output "firewall_id" {
  description = "ID of the Network Firewall"
  value       = aws_networkfirewall_firewall.this.id
}

output "firewall_arn" {
  description = "ARN of the Network Firewall"
  value       = aws_networkfirewall_firewall.this.arn
}

output "firewall_policy_arn" {
  description = "ARN of the Firewall Policy"
  value       = aws_networkfirewall_firewall_policy.this.arn
}

output "firewall_status" {
  description = "Status of the Network Firewall"
  value       = aws_networkfirewall_firewall.this.firewall_status
}

output "firewall_endpoints" {
  description = "Firewall endpoint information"
  value = aws_networkfirewall_firewall.this.firewall_status[0].sync_states
}
