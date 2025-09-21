#!/bin/bash

yum update -y

yum install -y python3 python3-pip git

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

mkdir -p /opt/account-app
cd /opt/account-app

cat > app.py << 'EOF'
${app_py_content}
EOF

cat > requirements.txt << 'EOF'
${requirements_content}
EOF

pip3 install -r requirements.txt

cat > /etc/systemd/system/account-app.service << EOF
[Unit]
Description=Account Service Flask App
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/account-app
Environment=TABLE_NAME=${table_name}
Environment=TABLE_REGION=${table_region}
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable account-app
systemctl start account-app

cat > /opt/account-app/status.sh << 'EOF'
#!/bin/bash
echo "=== Account Service Status ==="
systemctl status account-app --no-pager
echo ""
echo "=== Service Logs (last 20 lines) ==="
journalctl -u account-app --no-pager -n 20
EOF

chmod +x /opt/account-app/status.sh

echo "Account service setup completed at $(date)" >> /var/log/account-setup.log
