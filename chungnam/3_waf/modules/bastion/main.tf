data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-bastion-"
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
    Name = "${var.project_name}-bastion-sg"
  }
}

resource "aws_iam_role" "bastion_role" {
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

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.project_name}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_instance" "bastion" {
  ami                     = data.aws_ami.amazon_linux.id
  instance_type           = var.instance_type
  key_name                = var.key_name
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [aws_security_group.bastion.id]
  iam_instance_profile    = aws_iam_instance_profile.bastion_profile.name
  associate_public_ip_address = true
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {}))
  
  tags = {
    Name = "waf-bastion"
  }
}
