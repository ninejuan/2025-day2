variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "ID of the VPC where instance will be created"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where instance will be created"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "public_key_content" {
  description = "Public key content for the key pair"
  type        = string
}
