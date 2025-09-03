locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  app_port            = var.app_port
  tags                = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  region       = var.region
  tags         = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  tags         = local.common_tags
}

module "ecs" {
  source = "./modules/ecs"

  project_name           = var.project_name
  vpc_id                = module.vpc.vpc_id
  app_image             = var.app_image
  ecr_image_url         = "${module.ecr.ecr_repository_url}:latest"
  app_port              = var.app_port
  app_count             = 1
  cpu                   = var.cpu
  memory                = var.memory
  execution_role_arn    = module.iam.ecs_task_execution_role_arn
  security_group_ids    = [module.vpc.ecs_tasks_security_group_id]
  ecs_tasks_security_group_id = module.vpc.ecs_tasks_security_group_id
  subnet_ids            = module.vpc.public_subnet_ids
  region                = var.region
  ecr_image_ready       = module.ecr.docker_build_push
  tags                  = local.common_tags
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name    = var.project_name
  cpu_threshold  = var.cpu_threshold
  cluster_name   = module.ecs.ecs_cluster_name
  service_name   = module.ecs.ecs_service_name
  tags           = local.common_tags
}

module "bastion" {
  source = "./modules/bastion"

  project_name        = var.project_name
  instance_type       = var.bastion_instance_type
  security_group_ids  = [module.vpc.bastion_security_group_id]
  subnet_id           = module.vpc.public_subnet_ids[0]
  user_data           = file("${path.module}/bastion-user-data.sh")
  tags                = local.common_tags
}
