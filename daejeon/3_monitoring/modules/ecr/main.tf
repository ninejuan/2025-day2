resource "aws_ecr_repository" "wsi_repo" {
  name                 = "${var.name_prefix}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-app"
  })
}

resource "aws_ecr_lifecycle_policy" "wsi_repo_policy" {
  repository = aws_ecr_repository.wsi_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "null_resource" "docker_build_push" {
  depends_on = [aws_ecr_repository.wsi_repo]

  triggers = {
    dockerfile_hash = filemd5("${var.app_files_path}/Dockerfile")
    app_hash        = filemd5("${var.app_files_path}/app.py")
    ecr_repo_url    = aws_ecr_repository.wsi_repo.repository_url
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.wsi_repo.repository_url}
      
      cd ${var.app_files_path}
      docker build --platform linux/amd64 -t ${aws_ecr_repository.wsi_repo.name}:latest .
      
      docker tag ${aws_ecr_repository.wsi_repo.name}:latest ${aws_ecr_repository.wsi_repo.repository_url}:latest
      
      docker push ${aws_ecr_repository.wsi_repo.repository_url}:latest
    EOT
  }
}
