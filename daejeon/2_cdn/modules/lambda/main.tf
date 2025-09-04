data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source {
    content = file("${path.module}/lambda_function.py")
    filename = "lambda_function.py"
  }
}

resource "aws_iam_role" "lambda_edge_role" {
  name = "${var.project_name}-lambda-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-edge-role"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_edge_basic" {
  role       = aws_iam_role.lambda_edge_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "drm_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role            = aws_iam_role.lambda_edge_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.13"
  timeout         = 5
  memory_size     = 128

  # Lambda@Edge는 us-east-1에서만 생성 가능

  tags = {
    Name = var.function_name
  }
}

resource "aws_lambda_function" "drm_function_version" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.function_name}-version"
  role            = aws_iam_role.lambda_edge_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.13"
  timeout         = 5
  memory_size     = 128
  publish         = true

  # Lambda@Edge는 us-east-1에서만 생성 가능

  tags = {
    Name = "${var.function_name}-version"
  }

  depends_on = [aws_lambda_function.drm_function]
}
