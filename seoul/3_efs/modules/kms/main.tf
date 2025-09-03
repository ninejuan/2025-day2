resource "aws_kms_key" "main" {
  description             = "KMS key for EFS encryption and IAM role permissions"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = var.key_alias
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_kms_key_policy" "main" {
  key_id = aws_kms_key.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EFS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "elasticfilesystem.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "elasticfilesystem.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      }
    ], var.iam_role_arn != null ? [
      {
        Sid    = "Allow IAM role to use the key"
        Effect = "Allow"
        Principal = {
          AWS = var.iam_role_arn
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ] : [])
  })
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
