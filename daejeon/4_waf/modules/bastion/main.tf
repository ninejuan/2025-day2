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

resource "aws_security_group" "bastion_sg" {
  name_prefix = "${var.name_prefix}-bastion-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-bastion-sg"
  })
}

resource "aws_iam_role" "bastion_role" {
  name = "${var.name_prefix}-bastion-role"

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

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_policy_attachment" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "bastion_full_access_policy" {
  name        = "${var.name_prefix}-bastion-full-access-policy"
  description = "Policy for bastion to access all AWS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "wafv2:*",
          "cloudwatch:*",
          "logs:*",
          "iam:ListRoles",
          "iam:ListPolicies",
          "iam:GetRole",
          "iam:GetPolicy",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "bastion_full_access_policy_attachment" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_full_access_policy.arn
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.name_prefix}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

locals {
  user_data = templatefile("${path.module}/user_data.sh", {})
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id             = var.public_subnet_ids[0]
  iam_instance_profile  = aws_iam_instance_profile.bastion_profile.name
  user_data             = local.user_data
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-bastion"
    Type = "Bastion"
  })
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-bastion-eip"
  })
}
