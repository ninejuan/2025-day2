#!/bin/bash
yum update -y
yum install -y jq curl git docker

# Docker 서비스 시작
systemctl enable docker
systemctl start docker

# kubectl 설치
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# GitHub CLI 설치
yum install -y dnf
dnf install -y 'dnf-command(config-manager)'
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf install -y gh

# SSM Agent 시작
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# EKS 클러스터 인증 설정
aws eks update-kubeconfig --region ${region} --name gac-eks-cluster

# Docker 그룹에 ec2-user 추가
usermod -a -G docker ec2-user

cd /home/ec2-user
mkdir actions-runner && cd actions-runner

curl -o actions-runner-linux-x64-2.328.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.328.0.tar.gz