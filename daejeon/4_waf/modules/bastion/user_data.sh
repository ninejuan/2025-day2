#!/bin/bash

# Update system
yum update -y

# Install basic tools
yum install -y htop vim wget curl

# Configure SSH
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# Configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Create a welcome message
cat > /etc/motd << 'EOF'
========================================
    WAF XXE Protection - Bastion Host
========================================
This is a bastion host for accessing the XXE server.
Use SSH to connect to the XXE server from here.

XXE Server: Check the EC2 console for the private IP
========================================
EOF
