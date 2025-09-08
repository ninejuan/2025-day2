data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ec2" {
  name_prefix = "${var.name_prefix}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "All TCP Traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All UDP Traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

resource "aws_iam_role" "ec2" {
  name = "${var.name_prefix}-role"

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

resource "aws_iam_role_policy" "ec2" {
  name = "${var.name_prefix}-policy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*",
          "vpc-lattice:*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_instance" "main" {
  count = length(var.subnet_ids)

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id             = var.subnet_ids[count.index]
  iam_instance_profile  = aws_iam_instance_profile.ec2.name

  user_data = base64encode(templatefile("${path.module}/${var.user_data_script}", {
    ecr_repository_url = var.ecr_repository_url
  }))

  tags = {
    Name = "${var.name_prefix}-${count.index + 1}"
  }
}

resource "aws_lb_target_group_attachment" "main" {
  count = length(aws_instance.main)

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.main[count.index].id
  port             = 8000
}
