resource "aws_efs_file_system" "main" {
  creation_token = var.file_system_name
  encrypted      = true
  kms_key_id     = var.kms_key_arn

  tags = {
    Name = var.file_system_name
  }
}

resource "aws_efs_mount_target" "az_b" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[0]
  security_groups = var.security_group_ids

  ip_address = var.mount_target_ips[0]
}

resource "aws_efs_mount_target" "az_c" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[1]
  security_groups = var.security_group_ids

  ip_address = var.mount_target_ips[1]
}

resource "aws_efs_access_point" "main" {
  file_system_id = aws_efs_file_system.main.id

  root_directory {
    path = var.root_directory_path
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = {
    Name = var.access_point_name
  }
}

resource "aws_efs_file_system_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAppInstancesAccessToEFS"
        Effect = "Allow"
        Principal = {
          AWS = var.iam_role_arn
        }
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "true"
          }
          StringEquals = {
            "aws:PrincipalTag/AppRole" = "wsi-app"
          }
          IpAddress = {
            "aws:SourceIp" = var.app_instance_ips
          }
          DateGreaterThan = {
            "aws:CurrentTime" = "2025-09-20T03:00:00Z"
          }
          DateLessThan = {
            "aws:CurrentTime" = "2025-09-26T18:00:00Z"
          }
        }
      },
      {
        Sid    = "ExplicitlyDenyBastionAccess"
        Effect = "Deny"
        Principal = "*"
        Action   = "*"
        Resource = "*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = [var.bastion_ip]
          }
        }
      }
    ]
  })
}
