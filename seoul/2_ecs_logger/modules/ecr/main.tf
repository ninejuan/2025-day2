resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-python-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ecr-repo"
  })
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "최신 5개 이미지만 유지"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "null_resource" "docker_build_push" {
  depends_on = [aws_ecr_repository.app]

  provisioner "local-exec" {
    command = <<-EOT
      echo "ECR 리포지토리 생성 완료: ${aws_ecr_repository.app.repository_url}"
      echo "Docker 이미지 빌드 및 푸시를 시작합니다..."
      
      # ECR 로그인
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}
      
      # Docker 이미지 빌드 (AMD64 플랫폼 지정)
      docker build --platform linux/amd64 -t ${aws_ecr_repository.app.repository_url}:latest ${path.module}/../../app-files
      
      # 이미지 푸시
      docker push ${aws_ecr_repository.app.repository_url}:latest
      
      echo "Docker 이미지 빌드 및 푸시 완료!"
    EOT
  }

  triggers = {
    ecr_repository_url = aws_ecr_repository.app.repository_url
    app_files_hash     = filemd5("${path.module}/../../app-files/main.py")
    platform           = "linux/amd64"
  }
}
