resource "random_integer" "bucket_suffix" {
  min = 100
  max = 999
}

resource "aws_s3_bucket" "drm_bucket" {
  bucket = "web-drm-bucket-${random_integer.bucket_suffix.result}"

  tags = {
    Name        = "web-drm-bucket-${random_integer.bucket_suffix.result}"
    Project     = var.project_name
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "drm_bucket" {
  bucket = aws_s3_bucket.drm_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "drm_bucket" {
  bucket = aws_s3_bucket.drm_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "drm_bucket" {
  bucket = aws_s3_bucket.drm_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "drm_bucket" {
  count = var.cloudfront_distribution_arn != "" ? 1 : 0
  
  bucket = aws_s3_bucket.drm_bucket.id

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
        Resource = "${aws_s3_bucket.drm_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.drm_bucket]
}

resource "aws_s3_bucket_cors_configuration" "drm_bucket" {
  bucket = aws_s3_bucket.drm_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_object" "media_folder" {
  bucket = aws_s3_bucket.drm_bucket.id
  key    = "media/"
}

resource "aws_s3_object" "sample_videos" {
  for_each = var.sample_videos

  bucket = aws_s3_bucket.drm_bucket.id
  key    = "media/${each.key}"
  source = each.value
  etag   = filemd5(each.value)

  depends_on = [aws_s3_object.media_folder]
}
