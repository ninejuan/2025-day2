terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc_a" {
  source = "./modules/vpc"
  
  vpc_name = "VPC-A"
  vpc_cidr = "10.1.0.0/16"
  
  public_subnet_cidr  = "10.1.1.0/24"
  private_subnet_cidr = "10.1.2.0/24"
  
  availability_zone = "ap-southeast-1a"
  subnet_name_prefix = "va"
  availability_zone_suffix = "a"
  
  tags = {
    Name = "VPC-A"
    Environment = var.environment
  }
}

module "vpc_b" {
  source = "./modules/vpc"
  
  vpc_name = "VPC-B"
  vpc_cidr = "10.2.0.0/16"
  
  public_subnet_cidr  = "10.2.1.0/24"
  private_subnet_cidr = "10.2.2.0/24"
  
  availability_zone = "ap-southeast-1b"
  subnet_name_prefix = "vb"
  availability_zone_suffix = "b"
  
  tags = {
    Name = "VPC-B"
    Environment = var.environment
  }
}

resource "aws_dynamodb_table" "service_b_table" {
  name           = "service-b-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "service-b-table"
    Environment = var.environment
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = file("${path.module}/modules/ec2/keys/bastion-key.pub")
}

module "bastion_iam" {
  source = "./modules/iam"
  
  role_name = "bastion-role"
  instance_profile_name = "bastion-profile"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  
  tags = {
    Name = "bastion-iam"
    Environment = var.environment
  }
}

module "service_a_iam" {
  source = "./modules/iam"
  
  role_name = "service-a-role"
  instance_profile_name = "service-a-profile"
  
  tags = {
    Name = "service-a-iam"
    Environment = var.environment
  }
}

module "service_b_iam" {
  source = "./modules/iam"
  
  role_name = "service-b-role"
  instance_profile_name = "service-b-profile"
  
  inline_policies = {
    "dynamodb-access" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query",
            "dynamodb:Scan"
          ]
          Resource = aws_dynamodb_table.service_b_table.arn
        }
      ]
    })
  }
  
  tags = {
    Name = "service-b-iam"
    Environment = var.environment
  }
}

module "bastion_sg" {
  source = "./modules/security_group"
  
  security_group_name = "bastion-sg"
  description = "Security group for Bastion host"
  vpc_id = module.vpc_a.vpc_id
  
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  tags = {
    Name = "bastion-sg"
    Environment = var.environment
  }
}

module "service_a_sg" {
  source = "./modules/security_group"
  
  security_group_name = "service-a-sg"
  description = "Security group for Service A"
  vpc_id = module.vpc_a.vpc_id
  
  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.bastion_sg.security_group_id]
    },
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = [module.bastion_sg.security_group_id]
    }
  ]
  
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  tags = {
    Name = "service-a-sg"
    Environment = var.environment
  }
}

module "service_b_sg" {
  source = "./modules/security_group"
  
  security_group_name = "service-b-sg"
  description = "Security group for Service B"
  vpc_id = module.vpc_b.vpc_id
  
  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks = ["10.1.0.0/16"]
    },
    {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks = ["10.1.0.0/16"]
    }
  ]
  
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  tags = {
    Name = "service-b-sg"
    Environment = var.environment
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "bastion" {
  source = "./modules/ec2"
  
  ami_id = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.bastion_key.key_name
  subnet_id = module.vpc_a.public_subnet_id
  security_group_ids = [module.bastion_sg.security_group_id]
  iam_instance_profile_name = module.bastion_iam.instance_profile_name
  user_data_template = "${path.module}/modules/ec2/userdata/bastion-user-data.sh"
  instance_name = "lat-bastion"
  create_eip = true
  
  tags = {
    Name = "lat-bastion"
    Environment = var.environment
  }
}

module "service_a" {
  source = "./modules/ec2"
  
  ami_id = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.bastion_key.key_name
  subnet_id = module.vpc_a.private_subnet_id
  security_group_ids = [module.service_a_sg.security_group_id]
  iam_instance_profile_name = module.service_a_iam.instance_profile_name
  user_data_template = "${path.module}/modules/ec2/userdata/service-a-user-data.sh"
  instance_name = "service-a-ec2"
  create_eip = false
  
  tags = {
    Name = "service-a-ec2"
    Environment = var.environment
  }
}

module "service_b" {
  source = "./modules/ec2"
  
  ami_id = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.bastion_key.key_name
  subnet_id = module.vpc_b.private_subnet_id
  security_group_ids = [module.service_b_sg.security_group_id]
  iam_instance_profile_name = module.service_b_iam.instance_profile_name
  user_data_template = "${path.module}/modules/ec2/userdata/service-b-user-data.sh"
  instance_name = "service-b-ec2"
  create_eip = false
  
  tags = {
    Name = "service-b-ec2"
    Environment = var.environment
  }
}

module "lattice" {
  source = "./modules/lattice"
  
  service_network_name = "lattice-net"
  target_group_name = "service-b-tg"
  target_group_type = "INSTANCE"
  vpc_id = module.vpc_b.vpc_id
  
  target_instance_id = module.service_b.instance_id
  
  service_name = "service-b-lattice"
  listener_name = "service-b-listener"
  listener_protocol = "HTTP"
  listener_port = 80
  
  vpc_a_id = module.vpc_a.vpc_id
  vpc_b_id = module.vpc_b.vpc_id
  
  tags = {
    Name = "lattice"
    Environment = var.environment
  }
}
