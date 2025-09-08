
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  common_tags = {
    Project = "s3cdn"
    Environment = "production"
  }
}

module "vpc" {
  source = "./modules/vpc"
  
  providers = {
    aws = aws.kr
  }
  
  tags = local.common_tags
}

module "s3_kr" {
  source = "./modules/s3"
  
  providers = {
    aws = aws.kr
  }
  
  bucket_name = "skills-kr-cdn-web-static-${local.account_id}"
  region = "ap-northeast-2"
  distribution_id = module.cloudfront.distribution_id
  tags = merge(local.common_tags, {
    Name = "skills-kr-cdn-web-static-${local.account_id}"
  })
}

module "s3_us" {
  source = "./modules/s3"
  
  providers = {
    aws = aws.us
  }
  
  bucket_name = "skills-us-cdn-web-static-${local.account_id}"
  region = "us-east-1"
  distribution_id = module.cloudfront.distribution_id
  tags = merge(local.common_tags, {
    Name = "skills-us-cdn-web-static-${local.account_id}"
  })
}

module "mrap" {
  source = "./modules/mrap"
  
  providers = {
    aws.kr = aws.kr
    aws.us = aws.us
  }
  
  mrap_name = "skills-mrap"
  kr_bucket_name = module.s3_kr.bucket_name
  us_bucket_name = module.s3_us.bucket_name
  tags = local.common_tags
}

module "bastion" {
  source = "./modules/bastion"
  
  providers = {
    aws = aws.kr
  }
  
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
  key_name = aws_key_pair.s3cdn_key.key_name
  tags = local.common_tags
}

module "cloudfront" {
  source = "./modules/cloudfront"
  
  providers = {
    aws = aws.kr
  }
  
  mrap_alias = module.mrap.alias
  mrap_domain = module.mrap.domain
  kr_bucket_domain = module.s3_kr.bucket_regional_domain_name
  us_bucket_domain = module.s3_us.bucket_regional_domain_name
  tags = local.common_tags
  
  depends_on = [
    module.mrap
  ]
}

module "lambda_kr" {
  source = "./modules/lambda"
  
  providers = {
    aws = aws.kr
  }
  
  function_name = "skills-lambda-function-kr"
  role_name = "skills-lambda-role-kr"
  distribution_id = module.cloudfront.distribution_id
  tags = local.common_tags
  
  depends_on = [
    module.cloudfront
  ]
}

module "lambda_us" {
  source = "./modules/lambda"
  
  providers = {
    aws = aws.us
  }
  
  function_name = "skills-lambda-function-us"
  role_name = "skills-lambda-role-us"
  distribution_id = module.cloudfront.distribution_id
  tags = local.common_tags
  
  depends_on = [
    module.cloudfront
  ]
}

resource "aws_key_pair" "s3cdn_key" {
  provider   = aws.kr
  key_name   = "s3cdn-key"
  public_key = file("${path.module}/s3cdn-key.pub")
  
  tags = local.common_tags
}
