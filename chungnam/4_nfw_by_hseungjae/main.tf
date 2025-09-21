module "vpc" {
  source             = "./vpc"
  prefix             = var.prefix
  region             = var.region
  availability_zones = data.aws_availability_zones.available.names
}

module "bastion" {
  source  = "./bastion"
  prefix  = var.prefix
  subnets = module.vpc.app_subnets
  ami_id  = data.aws_ami.al2023_ami_amd.id
  vpc_id  = module.vpc.app_vpc_id

  depends_on = [module.vpc]
}
