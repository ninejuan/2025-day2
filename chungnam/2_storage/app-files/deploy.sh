#!/bin/bash

set -e

echo "🚀 Starting deployment of Storage Data Protection solution..."

echo "📋 Initializing Terraform..."
terraform init

echo "📋 Planning Terraform deployment..."
terraform plan

echo "📋 Applying Terraform configuration..."
terraform apply -auto-approve

BUCKET_NAME=$(terraform output -raw s3_bucket_name)
echo "✅ S3 Bucket created: $BUCKET_NAME"

echo "📁 Uploading provided files to incoming prefix..."
aws s3 cp provided_files/ s3://$BUCKET_NAME/incoming/ --recursive

echo "⏳ Waiting for Lambda function to process files..."
sleep 30

echo "🔍 Checking for masked files..."
aws s3 ls s3://$BUCKET_NAME/masked/

LAMBDA_NAME=$(terraform output -raw lambda_function_name)
MACIE_JOB_ID=$(terraform output -raw macie_job_id)

echo "✅ Deployment completed successfully!"
echo "📊 Resources created:"
echo "   - S3 Bucket: $BUCKET_NAME"
echo "   - Lambda Function: $LAMBDA_NAME"
echo "   - Macie Job ID: $MACIE_JOB_ID"
echo ""
echo "🔧 Next steps:"
echo "   1. Check masked files in S3: aws s3 ls s3://$BUCKET_NAME/masked/"
echo "   2. Start Macie job: aws macie2 start-classification-job --job-id $MACIE_JOB_ID"
echo "   3. Monitor Lambda logs: aws logs tail /aws/lambda/$LAMBDA_NAME --follow"
