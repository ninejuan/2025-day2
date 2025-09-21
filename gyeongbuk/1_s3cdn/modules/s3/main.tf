resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.main.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.distribution_id}"
          }
        }
      },
      {
        Sid       = "AllowCloudFrontFallback"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.main.arn}/*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_s3_object" "kr_file" {
  count = var.region == "ap-northeast-2" ? 1 : 0
  
  bucket = aws_s3_bucket.main.id
  key    = "index.html"
  source = "${path.root}/provided_files/kr/index.html"
  etag   = filemd5("${path.root}/provided_files/kr/index.html")
  content_type = "text/html"
  
  tags = var.tags
}

resource "aws_s3_object" "us_file" {
  count = var.region == "us-east-1" ? 1 : 0
  
  bucket = aws_s3_bucket.main.id
  key    = "index.html"
  source = "${path.root}/provided_files/us/index.html"
  etag   = filemd5("${path.root}/provided_files/us/index.html")
  content_type = "text/html"
  
  tags = var.tags
}

resource "aws_s3_object" "kr_prefixed" {
  count = var.region == "ap-northeast-2" ? 1 : 0

  bucket = aws_s3_bucket.main.id
  key    = "kr/index.html"
  source = "${path.root}/provided_files/kr/index.html"
  etag   = filemd5("${path.root}/provided_files/kr/index.html")
  content_type = "text/html"

  tags = var.tags
}

resource "aws_s3_object" "us_prefixed" {
  count = var.region == "us-east-1" ? 1 : 0

  bucket = aws_s3_bucket.main.id
  key    = "us/index.html"
  source = "${path.root}/provided_files/us/index.html"
  etag   = filemd5("${path.root}/provided_files/us/index.html")
  content_type = "text/html"

  tags = var.tags
}
