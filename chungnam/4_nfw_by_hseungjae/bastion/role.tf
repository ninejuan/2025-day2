resource "aws_iam_role" "bastion_role" {
  name     = "${var.prefix}-app-bastion-role"

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
    Name = "${var.prefix}-app-bastion-role"
  }
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name     = "${var.prefix}-app-bastion-role"
  role     = aws_iam_role.bastion_role.name
}

resource "aws_iam_role_policy_attachment" "administrator_policy_attachment" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

