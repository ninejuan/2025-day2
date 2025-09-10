variable "peering_name" {
  description = "Name for the VPC peering connection"
  type        = string
}

variable "vpc_id" {
  description = "ID of the requester VPC"
  type        = string
}

variable "peer_vpc_id" {
  description = "ID of the peer VPC"
  type        = string
}

variable "requester_vpc_cidr" {
  description = "CIDR block of the requester VPC"
  type        = string
}

variable "peer_vpc_cidr" {
  description = "CIDR block of the peer VPC"
  type        = string
}

variable "requester_private_route_table_ids" {
  description = "List of private route table IDs in the requester VPC"
  type        = list(string)
}

variable "requester_public_route_table_ids" {
  description = "List of public route table IDs in the requester VPC"
  type        = list(string)
}

variable "peer_private_route_table_ids" {
  description = "List of private route table IDs in the peer VPC"
  type        = list(string)
}

variable "peer_public_route_table_ids" {
  description = "List of public route table IDs in the peer VPC"
  type        = list(string)
}

variable "enable_security_group_rules" {
  description = "Whether to create security group rules for peering"
  type        = bool
  default     = false
}

variable "requester_security_group_id" {
  description = "Security group ID in the requester VPC (required if enable_security_group_rules is true)"
  type        = string
  default     = ""
}

variable "peer_security_group_id" {
  description = "Security group ID in the peer VPC (required if enable_security_group_rules is true)"
  type        = string
  default     = ""
}

variable "enable_dns_resolution" {
  description = "Whether to enable DNS resolution across the peering connection"
  type        = bool
  default     = true
}
