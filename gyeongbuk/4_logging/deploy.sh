#!/bin/bash

set -e

REGION="eu-west-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Building and pushing Docker images..."

cd app-files
docker build --platform linux/amd64 -t skills-app .
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
docker tag skills-app:latest $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/skills-app:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/skills-app:latest
cd ..

cd firelens-files
docker build --platform linux/amd64 -t skills-firelens .
docker tag skills-firelens:latest $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/skills-firelens:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/skills-firelens:latest
cd ..

echo "Docker images built and pushed successfully!"

echo "Updating ECS service..."
aws ecs update-service \
    --cluster skills-log-cluster \
    --service app \
    --force-new-deployment \
    --region $REGION

echo "ECS service updated. Deployment in progress..."
