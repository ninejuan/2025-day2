#!/bin/bash
yum update -y

# Install and configure SSM agent
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install additional tools for testing
yum install -y curl wget telnet nmap-ncat bind-utils

# Create a test user for verification
useradd -m testuser
echo "testuser:password123" | chpasswd

# Ensure SSM agent is running
systemctl restart amazon-ssm-agent

# Log the status for debugging
systemctl status amazon-ssm-agent > /var/log/ssm-status.log 2>&1
