resource "aws_lambda_function" "conflict_resolver" {
  filename         = "conflict_resolver.zip"
  function_name    = var.function_name
  role            = var.lambda_role_arn
  handler         = "conflict_resolver.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }

  depends_on = [
    data.archive_file.lambda_zip
  ]

  tags = {
    Name = var.function_name
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "conflict_resolver.zip"
  source {
    content = file("${path.module}/conflict_resolver.py")
    filename = "conflict_resolver.py"
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "dynamodb_stream_rule" {
  name        = "${var.function_name}-stream-rule"
  description = "Trigger Lambda on DynamoDB stream events"

  event_pattern = jsonencode({
    source      = ["aws.dynamodb"]
    detail-type = ["DynamoDB Stream Record"]
    detail = {
      eventName = ["INSERT", "MODIFY"]
      dynamodb = {
        StreamViewType = ["NEW_AND_OLD_IMAGES"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.dynamodb_stream_rule.name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.conflict_resolver.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.conflict_resolver.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.dynamodb_stream_rule.arn
}
