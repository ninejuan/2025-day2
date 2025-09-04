#!/bin/bash
yum update -y
yum install -y awscli jq curl

# AWS CLI 설정
mkdir -p /home/ec2-user/.aws
cat > /home/ec2-user/.aws/config << EOF
[default]
region = ap-southeast-1
output = json
EOF

chown -R ec2-user:ec2-user /home/ec2-user/.aws

# 시스템 정보 확인
echo "Bastion Host 설정 완료" > /tmp/bastion-setup.log
echo "Date: $(date)" >> /tmp/bastion-setup.log
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" >> /tmp/bastion-setup.log
echo "Region: ap-southeast-1" >> /tmp/bastion-setup.log
