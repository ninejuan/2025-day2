#!/bin/bash
yum update -y
yum install -y python3 python3-pip docker git

systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

mkdir -p /home/ec2-user/app-files

cat > /home/ec2-user/app-files/consumer_app.py << 'EOF'
${consumer_app_content}
EOF

cat > /home/ec2-user/app-files/consumer_requirements.txt << 'EOF'
${consumer_requirements_content}
EOF

chown -R ec2-user:ec2-user /home/ec2-user/app-files

cd /home/ec2-user/app-files
pip3 install -r consumer_requirements.txt

cat > /etc/systemd/system/consumer-app.service << EOF
[Unit]
Description=Consumer App
After=network.target

[Service]
Type=exec
User=ec2-user
WorkingDirectory=/home/ec2-user/app-files
ExecStart=/usr/bin/python3 /home/ec2-user/app-files/consumer_app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable consumer-app
systemctl start consumer-app
