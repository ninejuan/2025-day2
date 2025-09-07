#!/bin/bash
yum update -y
yum install -y python3 python3-pip git amazon-ssm-agent

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

APP_DIR="/opt/waf-app"
APP_USER="ec2-user"

mkdir -p $APP_DIR
cd $APP_DIR

pip3 install flask

cat > main.py << 'MAIN_EOF'
${main_py_content}
MAIN_EOF

mkdir -p utils
touch utils/__init__.py

cat > utils/query_builder.py << 'QUERY_EOF'
${query_builder_content}
QUERY_EOF

chown -R $APP_USER:$APP_USER $APP_DIR

cat > /etc/systemd/system/waf-app.service << 'SERVICE_EOF'
[Unit]
Description=WAF Test Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/waf-app
ExecStart=/usr/bin/python3 main.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=waf-app

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable waf-app
systemctl start waf-app
