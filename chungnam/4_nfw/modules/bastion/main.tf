data "aws_ssm_parameter" "ubuntu_24_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_iam_role" "bastion_role" {
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

  tags = {
    Name = "${var.instance_name}-role"
  }
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "bastion_ec2_role_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.bastion_role.name

  tags = {
    Name = "${var.instance_name}-profile"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for bastion host"
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
    Name = "${var.instance_name}-sg"
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = var.key_pair_name
  public_key = var.public_key_content

  tags = {
    Name = var.key_pair_name
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ssm_parameter.ubuntu_24_ami.value
  instance_type          = var.instance_type
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile.name
  
  user_data = base64encode(file("${path.module}/user_data.sh"))

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = var.instance_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.bastion_ssm_policy,
    aws_iam_role_policy_attachment.bastion_ec2_role_policy,
    aws_iam_instance_profile.bastion_profile
  ]
}
