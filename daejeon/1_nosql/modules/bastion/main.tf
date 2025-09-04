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

resource "aws_iam_role" "bastion" {
  name = "${var.project_name}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "bastion_dynamodb_policy" {
  name        = "${var.project_name}-bastion-dynamodb-policy"
  description = "Policy for bastion to access DynamoDB"

  policy = jsonencode({
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
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:TransactWriteItems",
          "dynamodb:TransactGetItems"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.table_name}",
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.table_name}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_dynamodb_policy_attachment" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.bastion_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_policy_attachment" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-bastion-profile"
  role = aws_iam_role.bastion.name
}

variable "bastion_security_group_id" {
  description = "Bastion security group ID from VPC module"
  type        = string
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.project_name}-bastion-key"
  public_key = file("${path.module}/../../nosql-key.pub")

  tags = {
    Name = "${var.project_name}-bastion-key"
  }
}

locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    table_name = var.table_name
    table_region = var.aws_region
    app_py_content = file("${path.module}/../../app-files/app.py")
    requirements_content = file("${path.module}/../../app-files/requirements.txt")
  })
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [var.bastion_security_group_id]
  subnet_id             = var.public_subnet_id
  iam_instance_profile  = aws_iam_instance_profile.bastion.name
  user_data             = local.user_data

  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-bastion"
    Type = "Bastion"
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-bastion-eip"
  }
}
