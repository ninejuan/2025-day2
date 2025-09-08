resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = file("${var.key_name}.pub")
}

module "consumer_vpc" {
  source = "./modules/vpc"

  vpc_name     = "skills-consumer-vpc"
  vpc_cidr     = "172.168.0.0/16"
  igw_name     = "skills-consumer-igw"
  nat_names    = ["skills-consumer-nat-a", "skills-consumer-nat-c"]
  
  public_subnets = [
    {
      name = "skills-consumer-public-subnet-a"
      cidr = "172.168.0.0/24"
      az   = "ap-southeast-1a"
    },
    {
      name = "skills-consumer-public-subnet-c"
      cidr = "172.168.1.0/24"
      az   = "ap-southeast-1c"
    }
  ]
  
  private_subnets = [
    {
      name = "skills-consumer-workload-subnet-a"
      cidr = "172.168.2.0/24"
      az   = "ap-southeast-1a"
      rt_name = "skills-consumer-workload-rt-a"
    },
    {
      name = "skills-consumer-workload-subnet-c"
      cidr = "172.168.3.0/24"
      az   = "ap-southeast-1c"
      rt_name = "skills-consumer-workload-rt-c"
    }
  ]
  
  public_rt_name = "skills-consumer-public-rt"
}

module "service_vpc" {
  source = "./modules/vpc"

  vpc_name     = "skills-service-vpc"
  vpc_cidr     = "10.0.0.0/16"
  igw_name     = "skills-service-igw"
  nat_names    = ["skills-service-nat-a", "skills-service-nat-c"]
  
  public_subnets = [
    {
      name = "skills-service-public-subnet-a"
      cidr = "10.0.0.0/24"
      az   = "ap-southeast-1a"
    },
    {
      name = "skills-service-public-subnet-c"
      cidr = "10.0.1.0/24"
      az   = "ap-southeast-1c"
    }
  ]
  
  private_subnets = [
    {
      name = "skills-service-workload-subnet-a"
      cidr = "10.0.2.0/24"
      az   = "ap-southeast-1a"
      rt_name = "skills-service-workload-rt-a"
    },
    {
      name = "skills-service-workload-subnet-c"
      cidr = "10.0.3.0/24"
      az   = "ap-southeast-1c"
      rt_name = "skills-service-workload-rt-c"
    }
  ]
  
  public_rt_name = "skills-service-public-rt"
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id            = module.consumer_vpc.vpc_id
  public_subnet_id  = module.consumer_vpc.public_subnet_ids[0]
  key_name         = var.key_name
  
  depends_on = [aws_key_pair.main]
}

module "lattice" {
  source = "./modules/lattice"

  consumer_vpc_id = module.consumer_vpc.vpc_id
  service_vpc_id  = module.service_vpc.vpc_id
  
  service_subnet_ids = module.service_vpc.private_subnet_ids
  app_alb_arn        = module.app_alb.alb_arn
  
  depends_on = [module.app_alb]
}

module "consumer_alb" {
  source = "./modules/alb"

  name               = "skills-consumer-alb"
  vpc_id            = module.consumer_vpc.vpc_id
  subnet_ids        = module.consumer_vpc.public_subnet_ids
  is_internal       = false
  target_group_name = "skills-consumer-tg"
}

module "app_alb" {
  source = "./modules/alb"

  name               = "skills-app-alb"
  vpc_id            = module.service_vpc.vpc_id
  subnet_ids        = module.service_vpc.private_subnet_ids
  is_internal       = true
  target_group_name = "skills-app-tg"
}

module "consumer_servers" {
  source = "./modules/ec2"

  name_prefix       = "skills-consumer"
  vpc_id           = module.consumer_vpc.vpc_id
  subnet_ids       = module.consumer_vpc.private_subnet_ids
  target_group_arn = module.consumer_alb.target_group_arn
  key_name         = var.key_name
  user_data_script = "consumer_server_minimal.sh"
  ecr_repository_url = module.ecr.repository_url
  
  depends_on = [aws_key_pair.main]
}

module "app_servers" {
  source = "./modules/ec2"

  name_prefix       = "skills-app"
  vpc_id           = module.service_vpc.vpc_id
  subnet_ids       = module.service_vpc.private_subnet_ids
  target_group_arn = module.app_alb.target_group_arn
  key_name         = var.key_name
  user_data_script = "app_server_minimal.sh"
  ecr_repository_url = module.ecr.repository_url
  
  depends_on = [aws_key_pair.main]
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "ecr" {
  source = "./modules/ecr"
}
