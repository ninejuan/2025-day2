data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                = var.vpc_cidr
  private_subnet_a_cidr   = var.private_subnet_a_cidr
  private_subnet_b_cidr   = var.private_subnet_b_cidr
  public_subnet_a_cidr    = var.public_subnet_a_cidr
  public_subnet_b_cidr    = var.public_subnet_b_cidr
  availability_zones      = data.aws_availability_zones.available.names
}

resource "aws_security_group" "alb" {
  name_prefix = "skills-log-alb-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "skills-log-alb-sg"
  }
}

resource "aws_security_group" "ecs" {
  name_prefix = "skills-log-ecs-sg"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "skills-log-ecs-sg"
  }
}

resource "aws_security_group_rule" "alb_to_ecs" {
  type                     = "egress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ecs_from_alb" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs.id
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_a_id
  key_name          = var.key_name
  instance_type     = var.bastion_instance_type
}

module "alb" {
  source = "./modules/alb"

  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = [module.vpc.public_subnet_a_id, module.vpc.public_subnet_b_id]
  alb_security_group_id = aws_security_group.alb.id
}

module "ecr" {
  source = "./modules/ecr"
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = [module.vpc.private_subnet_a_id, module.vpc.private_subnet_b_id]
  alb_target_group_arn      = module.alb.target_group_arn
  ecs_security_group_id     = aws_security_group.ecs.id
  ecr_app_repository_url    = module.ecr.app_repository_url
  ecr_firelens_repository_url = module.ecr.firelens_repository_url
  cloudwatch_log_group_name = module.cloudwatch.log_group_name
  app_image_pushed          = module.ecr.app_image_pushed
  firelens_image_pushed     = module.ecr.firelens_image_pushed
}
