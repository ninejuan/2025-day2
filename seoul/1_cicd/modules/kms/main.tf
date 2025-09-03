resource "aws_kms_key" "main" {
  description             = "GAC Competition KMS Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "gac-kms-key"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/gac-key"
  target_key_id = aws_kms_key.main.key_id
}
