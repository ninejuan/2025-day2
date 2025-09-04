module "vpc" {
  source = "./modules/vpc"

  project_name           = var.project_name
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
}

module "bastion" {
  source = "./modules/bastion"

  project_name      = var.project_name
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  key_pair_name    = var.key_pair_name
  public_key       = file("${path.module}/web-cdn-bastion-key.pub")
  instance_type    = var.bastion_instance_type
  user_data        = file("${path.module}/modules/bastion/user_data.sh")

  depends_on = [module.vpc]
}

module "lambda" {
  source = "./modules/lambda"

  project_name  = var.project_name
  function_name = "web-drm-function"
}

module "s3" {
  source = "./modules/s3"

  project_name                = var.project_name
  cloudfront_distribution_arn = "" 
  sample_videos              = var.sample_videos
}

module "cloudfront" {
  source = "./modules/cloudfront"

  project_name                = var.project_name
  function_name              = "web-cdn-function"
  distribution_name          = "web-cdn"
  s3_bucket_name             = module.s3.bucket_name
  s3_bucket_domain_name      = module.s3.bucket_domain_name
  lambda_edge_arn            = module.lambda.lambda_function_version_arn

  depends_on = [module.lambda, module.s3]
}

resource "aws_s3_bucket_policy" "drm_bucket_policy_update" {
  bucket = module.s3.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAI"
        Effect = "Allow"
        Principal = {
          AWS = module.cloudfront.origin_access_identity_iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3.bucket_arn}/*"
      }
    ]
  })

  depends_on = [module.cloudfront]
}
