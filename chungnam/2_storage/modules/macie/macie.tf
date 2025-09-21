resource "aws_macie2_account" "macie" {
  count = var.enable_macie ? 1 : 0
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                      = "ENABLED"
}