resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

resource "aws_s3_bucket" "sensitive_data" {
  bucket = "${var.bucket_prefix}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.bucket_prefix}-${random_string.bucket_suffix.result}"
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "sensitive_data_versioning" {
  bucket = aws_s3_bucket.sensitive_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sensitive_data_encryption" {
  bucket = aws_s3_bucket.sensitive_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "sensitive_data_pab" {
  bucket = aws_s3_bucket.sensitive_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "incoming_folder" {
  bucket = aws_s3_bucket.sensitive_data.id
  key    = "incoming/"
  source = "/dev/null"

  tags = {
    Name = "incoming-folder"
  }
}

resource "aws_s3_object" "masked_folder" {
  bucket = aws_s3_bucket.sensitive_data.id
  key    = "masked/"
  source = "/dev/null"

  tags = {
    Name = "masked-folder"
  }
}

resource "aws_s3_object" "provided_files" {
  for_each = fileset("${path.root}/provided_files/", "*.txt")

  bucket = aws_s3_bucket.sensitive_data.id
  key    = "incoming/${each.value}"
  source = "${path.root}/provided_files/${each.value}"
  etag   = filemd5("${path.root}/provided_files/${each.value}")

  tags = {
    Name = each.value
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.sensitive_data.id

  lambda_function {
    id                  = "tf-s3-lambda-masking-trigger"
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incoming/"
  }

  depends_on = [var.lambda_permission_dependency]
}
