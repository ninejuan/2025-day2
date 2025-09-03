#!/bin/bash
yum update -y
yum install -y curl jq

# AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# 정리
rm -rf awscliv2.zip aws/

echo "Bastion Host 설정 완료: SSH, aws-cli, curl, jq 설치됨"
