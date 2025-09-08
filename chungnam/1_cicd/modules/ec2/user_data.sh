#!/bin/bash
set -e

yum update -y

yum install -y docker
systemctl start docker
systemctl enable docker

usermod -aG docker ec2-user
yum install -y git jq curl wget

