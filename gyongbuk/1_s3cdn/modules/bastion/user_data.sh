#!/bin/bash

# Update system
yum update -y

# Install required packages
yum install -y awscli2 curl jq

# Install and start SSM Agent (Amazon Linux 2023 has it preinstalled, but ensure it's running)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Configure AWS CLI
aws configure set region ${region}
