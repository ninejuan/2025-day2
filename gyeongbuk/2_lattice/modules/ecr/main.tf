data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ecr_repository" "main" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name = var.repository_name
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 1 untagged image"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "null_resource" "docker_build_push" {
  depends_on = [aws_ecr_repository.main]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.root}
      if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}
        docker build --platform linux/amd64 -t ${var.repository_name} .
        docker tag ${var.repository_name}:latest ${aws_ecr_repository.main.repository_url}:latest
        docker push ${aws_ecr_repository.main.repository_url}:latest
      else
        echo "Docker is not running or not installed. Skipping ECR image build."
        echo "The application will run using the fallback Python installation on EC2."
      fi
    EOT
  }

  triggers = {
    dockerfile_hash = filemd5("${path.root}/Dockerfile")
    app_hash       = filemd5("${path.root}/app-files/app.py")
    requirements_hash = filemd5("${path.root}/app-files/requirements.txt")
  }
}
