resource "aws_iam_role" "github_runner" {
  name = "gac-github-runner-role"

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

resource "aws_iam_policy" "github_runner_ecr" {
  name = "gac-github-runner-ecr-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "github_runner_eks" {
  name = "gac-github-runner-eks-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_runner_ecr" {
  policy_arn = aws_iam_policy.github_runner_ecr.arn
  role       = aws_iam_role.github_runner.name
}

resource "aws_iam_role_policy_attachment" "github_runner_eks" {
  policy_arn = aws_iam_policy.github_runner_eks.arn
  role       = aws_iam_role.github_runner.name
}

resource "aws_iam_role_policy_attachment" "github_runner_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.github_runner.name
}

resource "aws_iam_instance_profile" "github_runner" {
  name = "gac-github-runner-profile"
  role = aws_iam_role.github_runner.name
}

resource "aws_security_group" "github_runner" {
  name_prefix = "gac-github-runner-sg"
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
    Name = "gac-github-runner-sg"
  }
}

resource "aws_instance" "github_runner" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.github_runner.id]
  iam_instance_profile   = aws_iam_instance_profile.github_runner.name
  key_name               = var.key_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    region = var.aws_region
  }))

  tags = {
    Name = "gac-runner"
  }

  depends_on = [
    aws_iam_role_policy_attachment.github_runner_ecr,
    aws_iam_role_policy_attachment.github_runner_eks,
    aws_iam_role_policy_attachment.github_runner_ssm
  ]
}

data "aws_ami" "amazon_linux_2" {
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
