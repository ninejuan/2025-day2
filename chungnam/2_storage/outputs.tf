output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "s3_bucket_arn" {
  value = module.s3.bucket_arn
}

output "lambda_function_name" {
  value = module.lambda.function_name
}

output "lambda_function_arn" {
  value = module.lambda.function_arn
}

output "macie_job_id" {
  value = module.macie.job_id
}

output "bucket_suffix" {
  value = module.s3.bucket_suffix
}
