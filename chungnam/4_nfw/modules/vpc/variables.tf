variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "create_igw" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = false
}

variable "create_nat_gw" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = false
}

# Public Subnets
variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "public_subnet_names" {
  description = "List of public subnet names"
  type        = list(string)
  default     = []
}

# Peering Subnets
variable "peering_subnets" {
  description = "List of peering subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "peering_subnet_names" {
  description = "List of peering subnet names"
  type        = list(string)
  default     = []
}

# Firewall Subnets
variable "firewall_subnets" {
  description = "List of firewall subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "firewall_subnet_names" {
  description = "List of firewall subnet names"
  type        = list(string)
  default     = []
}

# Private Subnets
variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "private_subnet_names" {
  description = "List of private subnet names"
  type        = list(string)
  default     = []
}
