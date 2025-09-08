resource "aws_s3control_multi_region_access_point" "main" {
  details {
    name = var.mrap_name
    region {
      bucket = var.kr_bucket_name
    }
    region {
      bucket = var.us_bucket_name
    }
    public_access_block {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }
}

resource "aws_s3control_multi_region_access_point" "dummy" {
  details {
    name = "skills-mrap-dummy"
    region {
      bucket = var.kr_bucket_name
    }
    region {
      bucket = var.us_bucket_name
    }
    public_access_block {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }
}

resource "aws_s3control_multi_region_access_point_policy" "main" {
  details {
    name = aws_s3control_multi_region_access_point.main.details[0].name
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowCloudFrontServicePrincipal"
          Effect = "Allow"
          Principal = {
            Service = "cloudfront.amazonaws.com"
          }
          Action = "s3:GetObject"
          Resource = "${aws_s3control_multi_region_access_point.main.arn}/object/*"
          Condition = {
            StringEquals = {
              "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/*"
            }
          }
        }
      ]
    })
  }
}

data "aws_caller_identity" "current" {}
