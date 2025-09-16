resource "aws_ecr_repository" "dev" {
  name                 = "product/dev"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "product-dev"
    Environment = "dev"
  }
}

resource "aws_ecr_repository" "prod" {
  name                 = "product/prod"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "product-prod"
    Environment = "prod"
  }
}

resource "aws_ecr_lifecycle_policy" "dev" {
  repository = aws_ecr_repository.dev.name

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

resource "aws_ecr_lifecycle_policy" "prod" {
  repository = aws_ecr_repository.prod.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 20 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 20
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

resource "null_resource" "push_initial_dev_image" {
  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.root}/day2-product
      
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
      
      docker buildx build --platform linux/amd64 -t ${aws_ecr_repository.dev.repository_url}:v1.0.0 --push .
    EOT
  }

  depends_on = [aws_ecr_repository.dev]
}

resource "null_resource" "push_initial_prod_image" {
  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.root}/day2-product
      
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com
      
      docker buildx build --platform linux/amd64 -t ${aws_ecr_repository.prod.repository_url}:v1.0.0 --push .
    EOT
  }

  depends_on = [aws_ecr_repository.prod]
}
