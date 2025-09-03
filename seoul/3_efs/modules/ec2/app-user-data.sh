#!/bin/bash
set -e

yum update -y
yum install -y sshpass
yum install -y amazon-efs-utils
mkdir -p /mnt/efs
echo "ec2-user:wsi${student_number}" | chpasswd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
echo "App instance setup completed at $(date)" >> /var/log/user-data.log
