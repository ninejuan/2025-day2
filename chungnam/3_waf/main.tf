data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_key_pair" "waf_key" {
  key_name   = var.key_name
  public_key = file("${path.module}/waf-key.pub")
}

module "bastion" {
  source = "./modules/bastion"
  
  vpc_id             = data.aws_vpc.default.id
  subnet_id          = data.aws_subnets.default.ids[0]
  key_name           = aws_key_pair.waf_key.key_name
  instance_type      = var.bastion_instance_type
  project_name       = var.project_name
}

module "ec2" {
  source = "./modules/ec2"
  
  vpc_id             = data.aws_vpc.default.id
  subnet_id          = data.aws_subnets.default.ids[0]
  key_name           = aws_key_pair.waf_key.key_name
  instance_type      = var.app_instance_type
  project_name       = var.project_name
}

module "alb" {
  source = "./modules/alb"
  
  vpc_id             = data.aws_vpc.default.id
  subnet_ids         = data.aws_subnets.default.ids
  target_instance_id = module.ec2.instance_id
  project_name       = var.project_name
}

module "waf" {
  source = "./modules/waf"
  
  alb_arn      = module.alb.alb_arn
  project_name = var.project_name
}
