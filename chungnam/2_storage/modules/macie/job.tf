resource "aws_macie2_classification_job" "sensitive_data_scan" {
  job_type = "ONE_TIME"
  name     = "${var.prefix}-sensor-job"
  
  s3_job_definition {
    bucket_definitions {
      account_id = var.account_id
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

  custom_data_identifier_ids = [
    aws_macie2_custom_data_identifier.names.id,
    aws_macie2_custom_data_identifier.emails.id,
    aws_macie2_custom_data_identifier.phone_numbers.id,
    aws_macie2_custom_data_identifier.ssns.id,
    aws_macie2_custom_data_identifier.card_numbers.id,
    aws_macie2_custom_data_identifier.uuids.id
  ]

  depends_on = [
    aws_macie2_account.macie,
    aws_macie2_custom_data_identifier.names,
    aws_macie2_custom_data_identifier.emails,
    aws_macie2_custom_data_identifier.phone_numbers,
    aws_macie2_custom_data_identifier.ssns,
    aws_macie2_custom_data_identifier.card_numbers,
    aws_macie2_custom_data_identifier.uuids
  ]
}