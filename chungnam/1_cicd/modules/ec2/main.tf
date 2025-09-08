data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "runner_sg" {
  name_prefix = "${var.cluster_name}-runner-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "${var.cluster_name}-runner-sg"
  }
}

resource "aws_iam_role" "runner_role" {
  name = "${var.cluster_name}-runner-role"

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

resource "aws_iam_role_policy_attachment" "runner_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.runner_role.name
}

resource "aws_iam_role_policy_attachment" "runner_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.runner_role.name
}

resource "aws_iam_instance_profile" "runner_profile" {
  name = "${var.cluster_name}-runner-profile"
  role = aws_iam_role.runner_role.name
}

resource "aws_key_pair" "runner_key" {
  key_name   = "${var.cluster_name}-runner-key"
  public_key = var.public_key
}

resource "aws_instance" "runner" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.runner_key.key_name
  vpc_security_group_ids      = [aws_security_group.runner_sg.id]
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.runner_profile.name

  user_data = base64encode(file("${path.module}/user_data.sh"))

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = {
    Name = "${var.cluster_name}-runner"
  }
}

resource "aws_eip" "runner_eip" {
  instance = aws_instance.runner.id
  domain   = "vpc"

  tags = {
    Name = "${var.cluster_name}-runner-eip"
  }
}
