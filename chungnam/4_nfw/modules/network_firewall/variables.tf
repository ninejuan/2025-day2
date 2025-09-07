variable "firewall_name" {
  description = "Name of the Network Firewall"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where firewall will be deployed"
  type        = string
}

variable "firewall_subnet_ids" {
  description = "List of subnet IDs where firewall endpoints will be created"
  type        = list(string)
}

variable "home_net_cidrs" {
  description = "List of CIDR blocks representing the home network"
  type        = list(string)
  default     = ["10.0.0.0/16", "172.16.0.0/16"]
}
