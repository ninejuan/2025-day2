#!/bin/bash

set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

KR_BUCKET="skills-kr-cdn-web-static-${ACCOUNT_ID}"
US_BUCKET="skills-us-cdn-web-static-${ACCOUNT_ID}"

echo "Uploading files to KR bucket: ${KR_BUCKET}"
echo "Uploading files to US bucket: ${US_BUCKET}"

echo "Uploading KR files..."
aws s3 cp provided_files/kr/ s3://${KR_BUCKET}/kr/ --recursive

echo "Uploading US files..."
aws s3 cp provided_files/us/ s3://${US_BUCKET}/us/ --recursive

echo "File upload completed successfully!"

echo "Testing CloudFront invalidation..."

DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)

echo "Testing KR Lambda function..."
aws lambda invoke \
  --function-name "skills-lambda-function-kr" \
  --payload '{"path": "/kr/*"}' \
  --region ap-northeast-2 \
  /tmp/lambda_response_kr.json

echo "Testing US Lambda function..."
aws lambda invoke \
  --function-name "skills-lambda-function-us" \
  --payload '{"path": "/us/*"}' \
  --region us-east-1 \
  /tmp/lambda_response_us.json

echo "Lambda function tests completed!"

echo "KR Lambda response:"
cat /tmp/lambda_response_kr.json
echo ""
echo "US Lambda response:"
cat /tmp/lambda_response_us.json

rm -f /tmp/lambda_response_kr.json /tmp/lambda_response_us.json
