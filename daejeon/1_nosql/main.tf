# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "dynamodb" {
  source = "./modules/dynamodb"
  
  table_name = var.table_name
  providers = {
    aws.main = aws
    aws.eu_central = aws.eu_central
  }
}

module "lambda" {
  source = "./modules/lambda"
  
  function_name = var.lambda_function_name
  table_name = var.table_name
  table_arn = module.dynamodb.table_arn
  lambda_role_arn = module.dynamodb.lambda_role_arn
}

module "bastion" {
  source = "./modules/bastion"
  
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  bastion_security_group_id = module.vpc.bastion_security_group_id
  instance_type = var.ec2_instance_type
  table_name = var.table_name
  aws_region = var.aws_region
}

module "ec2" {
  source = "./modules/ec2"
  
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
  security_group_id = module.vpc.security_group_id
  instance_name = var.ec2_instance_name
  instance_type = var.ec2_instance_type
  table_name = var.table_name
  table_region = var.aws_region
}
