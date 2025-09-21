output "app_vpc_id" {
  value = module.app_vpc.vpc_id
}

output "app_subnets" {
  value = [aws_subnet.app_subnet_a.id, aws_subnet.app_subnet_b.id]
}