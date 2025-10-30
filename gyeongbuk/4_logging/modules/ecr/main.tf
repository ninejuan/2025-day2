resource "aws_ecr_repository" "app" {
  name                 = "skills-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
  tags = {
    Name = "skills-app"
  }
}

resource "aws_ecr_repository" "firelens" {
  name                 = "skills-firelens"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
  tags = {
    Name = "skills-firelens"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "firelens" {
  repository = aws_ecr_repository.firelens.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 10
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

resource "null_resource" "build_and_push_app" {
  depends_on = [aws_ecr_repository.app]

  triggers = {
    dockerfile_hash = filemd5("${path.root}/app-files/Dockerfile")
    app_hash        = filemd5("${path.root}/app-files/app.py")
    requirements_hash = filemd5("${path.root}/app-files/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<-EOF
      cd ${path.root}/app-files
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
      docker build --platform linux/amd64 -t skills-app .
      docker tag skills-app:latest ${aws_ecr_repository.app.repository_url}:latest
      docker push ${aws_ecr_repository.app.repository_url}:latest
    EOF
  }
}

resource "null_resource" "build_and_push_firelens" {
  depends_on = [aws_ecr_repository.firelens]

  triggers = {
    dockerfile_hash = filemd5("${path.root}/firelens-files/Dockerfile")
    extra_conf_hash = filemd5("${path.root}/firelens-files/extra.conf")
    parsers_conf_hash = filemd5("${path.root}/firelens-files/parsers.conf")
  }

  provisioner "local-exec" {
    command = <<-EOF
      cd ${path.root}/firelens-files
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
      docker build --platform linux/amd64 -t skills-firelens .
      docker tag skills-firelens:latest ${aws_ecr_repository.firelens.repository_url}:latest
      docker push ${aws_ecr_repository.firelens.repository_url}:latest
    EOF
  }
}
