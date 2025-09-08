#!/bin/bash
yum update -y
yum install -y python3 python3-pip docker git

systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

pip3 install fastapi uvicorn requests

mkdir -p /home/ec2-user/app

echo "${consumer_app_content}" | base64 -d > /home/ec2-user/app/consumer_app.py
chown -R ec2-user:ec2-user /home/ec2-user/app

cat > /etc/systemd/system/consumer-app.service << 'EOF'
[Unit]
Description=Consumer App
After=network.target

[Service]
Type=exec
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/python3 /home/ec2-user/app/consumer_app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable consumer-app
systemctl start consumer-app
