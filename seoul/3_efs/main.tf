

module "vpc" {
  source = "./modules/vpc"
  
  vpc_name = "efs-vpc"
  vpc_cidr = "10.128.0.0/16"
  
  public_subnets = {
    "efs-pub-b" = "10.128.0.0/20"
    "efs-pub-c" = "10.128.16.0/20"
  }
  
  private_subnets = {
    "efs-app-b" = "10.128.128.0/20"
    "efs-app-c" = "10.128.144.0/20"
  }
}

module "kms" {
  source = "./modules/kms"
  
  key_alias = "wsi-kms"
}

module "iam" {
  source = "./modules/iam"
  
  role_name = "wsi-ec2-efs-role"
  kms_key_arn = module.kms.key_arn
}

module "ec2" {
  source = "./modules/ec2"
  
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids["efs-pub-b"]
  private_subnet_ids = {
    "efs-app-b" = module.vpc.private_subnet_ids["efs-app-b"]
    "efs-app-c" = module.vpc.private_subnet_ids["efs-app-c"]
  }
  
  bastion_ip = "10.128.0.199"
  app1_ip = "10.128.128.199"
  app2_ip = "10.128.144.199"
  
  iam_instance_profile_name = module.iam.instance_profile_name
  student_number = var.student_number
}

module "efs" {
  source = "./modules/efs"
  
  file_system_name = "wsi-efs-fs"
  kms_key_arn = module.kms.key_arn
  
  subnet_ids = [
    module.vpc.private_subnet_ids["efs-app-b"],
    module.vpc.private_subnet_ids["efs-app-c"]
  ]
  
  security_group_ids = [module.vpc.efs_security_group_id]
  
  access_point_name = "wsi-efs-ap"
  root_directory_path = "/app/wsi${var.student_number}"
  
  app_instance_ips = [
    "10.128.128.199/32",
    "10.128.144.199/32"
  ]
  
  bastion_ip = "10.128.0.199/32"
  student_number = var.student_number
  iam_role_arn = module.iam.role_arn
}
