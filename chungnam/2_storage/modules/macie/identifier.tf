resource "aws_macie2_custom_data_identifier" "names" {
  name        = "names"
  regex       = "\\b(Mr\\.|Mrs\\.|Ms\\.)?\\s?[A-Z][a-z]+(?:\\s[A-Z][a-z]+)+\\b"
  description = "Custom identifier for names"
  
  depends_on = [aws_macie2_account.macie]
}

resource "aws_macie2_custom_data_identifier" "emails" {
  name        = "emails"
  regex       = "\\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.(com|net|org)\\b"
  description = "Custom identifier for email addresses"
  
  depends_on = [aws_macie2_account.macie]
}

resource "aws_macie2_custom_data_identifier" "phone_numbers" {
  name        = "phone_numbers"
  regex       = "\\b01[0-9]-\\d{3,4}-\\d{4}\\b"
  description = "Custom identifier for Korean phone numbers"
  
  depends_on = [aws_macie2_account.macie]
}

resource "aws_macie2_custom_data_identifier" "ssns" {
  name        = "ssns"
  regex       = "\\b\\d{3}-\\d{2}-\\d{4}\\b"
  description = "Custom identifier for social security numbers"
  
  depends_on = [aws_macie2_account.macie]
}

resource "aws_macie2_custom_data_identifier" "card_numbers" {
  name        = "card_numbers"
  regex       = "\\b(?:4\\d{3}|5[1-5]\\d{2})-(?:\\d{4}-){2}\\d{4}\\b"
  description = "Custom identifier for credit card numbers"
  
  depends_on = [aws_macie2_account.macie]
}

resource "aws_macie2_custom_data_identifier" "uuids" {
  name        = "uuids"
  regex       = "\\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\\b"
  description = "Custom identifier for UUIDs"
  
  depends_on = [aws_macie2_account.macie]
}