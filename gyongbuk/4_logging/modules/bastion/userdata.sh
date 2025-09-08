#!/bin/bash
yum update -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

yum install -y curl jq docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
