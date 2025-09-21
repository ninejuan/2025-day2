data "aws_caller_identity" "current" {}

module "lambda" {
  source = "./modules/lambda"

  function_name = var.lambda_function_name
  bucket_name   = module.s3.bucket_name
  bucket_arn    = module.s3.bucket_arn
}

module "s3" {
  source = "./modules/s3"

  bucket_prefix                = var.bucket_prefix
  lambda_function_arn          = module.lambda.function_arn
  lambda_permission_dependency = module.lambda.permission_dependency
}

module "macie" {
  source = "./modules/macie"

  prefix      = "wsc2025"
  bucket_name = module.s3.bucket_name
  account_id  = data.aws_caller_identity.current.account_id
  enable_macie = var.macie_enable
}

