#!/bin/bash

# Update system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Install required packages
pip3 install --upgrade pip

# Create application directory
mkdir -p /opt/xxe-app
cd /opt/xxe-app

# Create app.py
cat > app.py << 'EOF'
${app_py_content}
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
${requirements_content}
EOF

# Install Python dependencies
pip3 install -r requirements.txt
pip3 install flask lxml

# Create systemd service
cat > /etc/systemd/system/xxe-app.service << 'EOF'
[Unit]
Description=XXE Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/xxe-app
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R ec2-user:ec2-user /opt/xxe-app
chmod +x /opt/xxe-app/app.py

# Enable and start service
systemctl daemon-reload
systemctl enable xxe-app
systemctl start xxe-app

# Configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-port=5000/tcp
firewall-cmd --reload
