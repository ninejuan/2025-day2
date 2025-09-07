resource "aws_macie2_account" "main" {}

resource "time_sleep" "wait_for_macie_role" {
  create_duration = "60s"
  depends_on      = [aws_macie2_account.main]
}

resource "aws_macie2_classification_job" "sensor_job" {
  job_type = "ONE_TIME"
  name     = var.job_name

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

  depends_on = [time_sleep.wait_for_macie_role]
}

data "aws_caller_identity" "current" {}
