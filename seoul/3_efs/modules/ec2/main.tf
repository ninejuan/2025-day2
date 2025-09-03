resource "aws_key_pair" "main" {
  key_name   = "efs-key-${random_string.suffix.result}"
  public_key = file("${path.module}/ssh-key.pub")

  tags = {
    Name = "efs-ssh-key"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_security_group" "bastion" {
  name_prefix = "bastion-sg-"
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

  tags = {
    Name = "efs-bastion-sg"
  }
}

resource "aws_security_group" "app" {
  name_prefix = "app-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-app-sg"
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  key_name              = aws_key_pair.main.key_name
  subnet_id             = var.public_subnet_id
  private_ip            = var.bastion_ip
  vpc_security_group_ids = [aws_security_group.bastion.id]

  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/bastion-user-data.sh", {
    student_number = var.student_number
  }))

  tags = {
    Name = "efs-bastion"
    Type = "Bastion"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "app1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  key_name              = aws_key_pair.main.key_name
  subnet_id             = var.private_subnet_ids["efs-app-b"]
  private_ip            = var.app1_ip
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = var.iam_instance_profile_name

  user_data = base64encode(templatefile("${path.module}/app-user-data.sh", {
    student_number = var.student_number
  }))

  tags = {
    Name = "efs-app-1"
    Type = "App"
    AppRole = "wsi-app"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "app2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  key_name              = aws_key_pair.main.key_name
  subnet_id             = var.private_subnet_ids["efs-app-c"]
  private_ip            = var.app2_ip
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = var.iam_instance_profile_name

  user_data = base64encode(templatefile("${path.module}/app-user-data.sh", {
    student_number = var.student_number
  }))

  tags = {
    Name = "efs-app-2"
    Type = "App"
    AppRole = "wsi-app"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

data "aws_ami" "amazon_linux_2023" {
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
