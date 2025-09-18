resource "aws_macie2_account" "main" {}

# Custom Data Identifiers for original sensor job
resource "aws_macie2_custom_data_identifier" "email" {
  name                    = "wsc2025-email-cdi"
  description             = "Custom email identifier"
  regex                   = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
  maximum_match_distance  = 50
}

resource "aws_macie2_custom_data_identifier" "name" {
  name                    = "wsc2025-name-cdi"
  description             = "Custom person name identifier"
  regex                   = "(?i)\\b(?:mrs?\\.|ms\\.)?\\s?[A-Z][a-z]+(?:\\s+[A-Z][a-z]+)+\\b"
  maximum_match_distance  = 50
}

resource "aws_macie2_custom_data_identifier" "phone" {
  name                    = "wsc2025-phone-cdi"
  description             = "Custom phone identifier"
  regex                   = "\\b010-\\d{4}-\\d{4}\\b"
  maximum_match_distance  = 50
}

resource "aws_macie2_custom_data_identifier" "ssn" {
  name                    = "wsc2025-ssn-cdi"
  description             = "Custom SSN identifier"
  regex                   = "\\b\\d{3}-\\d{2}-\\d{4}\\b"
  maximum_match_distance  = 50
}

resource "aws_macie2_custom_data_identifier" "card" {
  name                    = "wsc2025-card-cdi"
  description             = "Custom credit card identifier"
  regex                   = "\\b\\d{4}-\\d{4}-\\d{4}-\\d{4}\\b"
  maximum_match_distance  = 50
}

resource "aws_macie2_custom_data_identifier" "uuid" {
  name                    = "wsc2025-uuid-cdi"
  description             = "Custom UUID identifier"
  regex                   = "\\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\\b"
  maximum_match_distance  = 50
}

resource "time_sleep" "wait_for_macie_role" {
  create_duration = "60s"
  depends_on      = [aws_macie2_account.main]
}

resource "aws_macie2_classification_job" "sensor_job" {
  job_type    = "ONE_TIME"
  name_prefix = var.job_name

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [var.bucket_name]
    }

    scoping {
      includes {
        and {
          simple_scope_term {
            comparator = "STARTS_WITH"
            key        = "OBJECT_KEY"
            values     = ["masked/"]
          }
        }
      }
    }
  }

  # Attach custom data identifiers
  custom_data_identifier_ids = [
    aws_macie2_custom_data_identifier.email.id,
    aws_macie2_custom_data_identifier.name.id,
    aws_macie2_custom_data_identifier.phone.id,
    aws_macie2_custom_data_identifier.ssn.id,
    aws_macie2_custom_data_identifier.card.id,
    aws_macie2_custom_data_identifier.uuid.id,
  ]

  depends_on = [time_sleep.wait_for_macie_role]
}

data "aws_caller_identity" "current" {}
