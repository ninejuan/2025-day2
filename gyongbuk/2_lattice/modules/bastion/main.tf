data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  
  filter {
    name   = "description"
    values = ["Amazon Linux 2023 AMI*"]
  }
}

resource "aws_security_group" "bastion" {
  name        = "skills-bastion-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
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

  tags = {
    Name = "skills-bastion-sg"
  }
}

resource "aws_iam_role" "bastion" {
  name = "skills-bastion-role"

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

resource "aws_iam_role_policy_attachment" "bastion_admin" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "skills-bastion-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_eip" "bastion" {
  domain   = "vpc"
  instance = aws_instance.bastion.id

  tags = {
    Name = "skills-bastion-eip"
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id             = var.public_subnet_id
  iam_instance_profile  = aws_iam_instance_profile.bastion.name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {}))

  tags = {
    Name = "skills-bastion"
  }
}
