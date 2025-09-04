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

resource "aws_iam_role" "ec2_role" {
  name = "${var.instance_name}-role"

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

resource "aws_iam_policy" "ec2_dynamodb_policy" {
  name        = "${var.instance_name}-dynamodb-policy"
  description = "Policy for EC2 to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.table_region}:*:table/${var.table_name}",
          "arn:aws:dynamodb:${var.table_region}:*:table/${var.table_name}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_ec2_policy" {
  name        = "${var.instance_name}-ec2-policy"
  description = "Policy for EC2 to access EC2 services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_dynamodb_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.instance_name}-key"
  public_key = file("${path.module}/../../nosql-key.pub")
}

locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    table_name = var.table_name
    table_region = var.table_region
    app_py_content = file("${path.module}/../../app-files/app.py")
    requirements_content = file("${path.module}/../../app-files/requirements.txt")
  })
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id             = var.subnet_id
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name
  user_data             = local.user_data
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = var.instance_name
  }
}

resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = {
    Name = "${var.instance_name}-eip"
  }
}
