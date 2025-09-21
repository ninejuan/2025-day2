resource "aws_ecr_repository" "app_repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.repository_name
  }
}

resource "aws_ecr_lifecycle_policy" "app_repo" {
  repository = aws_ecr_repository.app_repo.name

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

resource "null_resource" "docker_build_push" {
  depends_on = [aws_ecr_repository.app_repo]

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      
      REPO_URL="${aws_ecr_repository.app_repo.repository_url}"
      REGION="${var.aws_region}"
      VERSION="v1.0.0"
      
      aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPO_URL
      
      docker buildx create --name multiarch --use --bootstrap 2>/dev/null || docker buildx use multiarch
      
      docker buildx build \
        --platform linux/amd64 \
        --push \
        -t $REPO_URL:$VERSION \
        wsc2025-argocd-repo
    EOT

    working_dir = var.working_directory
  }

  triggers = {
    dockerfile_hash = filemd5("${var.working_directory}/wsc2025-argocd-repo/Dockerfile")
    version_hash    = filemd5("${var.working_directory}/wsc2025-argocd-repo/version")
    index_hash      = filemd5("${var.working_directory}/wsc2025-argocd-repo/index.html")
  }
}
