resource "aws_dynamodb_table" "main" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  deletion_protection_enabled = true

  tags = {
    Name = var.table_name
  }
}
