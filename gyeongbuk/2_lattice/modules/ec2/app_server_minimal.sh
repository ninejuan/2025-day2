#!/bin/bash
yum update -y
yum install -y python3 python3-pip docker git

systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
ECR_REPO_URL="${ecr_repository_url}"

if [ -n "$ECR_REPO_URL" ]; then
    aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPO_URL
    docker pull $ECR_REPO_URL:latest || echo "ECR image not found"
    
    if docker image inspect $ECR_REPO_URL:latest > /dev/null 2>&1; then
        docker run -d --name app-server -p 8000:8000 --restart always $ECR_REPO_URL:latest
    else
        echo "Running fallback"
        pip3 install fastapi uvicorn boto3 pydantic
        
        mkdir -p /home/ec2-user/app
        echo "ZnJvbSBmYXN0YXBpIGltcG9ydCBGYXN0QVBJCmltcG9ydCB1dmljb3JuCgphcHAgPSBGYXN0QVBJKCkKCkBhcHAuZ2V0KCIvaGVhbHRoIikKYXN5bmMgZGVmIGhlYWx0aF9jaGVjaygpOgogICAgcmV0dXJuIHsic3RhdHVzIjogIk9LIiwgIm1lc3NhZ2UiOiAiQXBwIHNlcnZlciJ9CgppZiBfX25hbWVfXyA9PSAiX19tYWluX18iOgogICAgdXZpY29ybi5ydW4oYXBwLCBob3N0PSIwLjAuMC4wIiwgcG9ydD04MDAwKQ==" | base64 -d > /home/ec2-user/app/app.py
        chown -R ec2-user:ec2-user /home/ec2-user/app
        
        cat > /etc/systemd/system/app-server.service << 'EOF'
[Unit]
Description=App Server
After=network.target

[Service]
Type=exec
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/python3 /home/ec2-user/app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

        systemctl daemon-reload
        systemctl enable app-server
        systemctl start app-server
    fi
else
    echo "No ECR URL"
    pip3 install fastapi uvicorn boto3 pydantic
    
    mkdir -p /home/ec2-user/app
    echo "ZnJvbSBmYXN0YXBpIGltcG9ydCBGYXN0QVBJCmltcG9ydCB1dmljb3JuCgphcHAgPSBGYXN0QVBJKCkKCkBhcHAuZ2V0KCIvaGVhbHRoIikKYXN5bmMgZGVmIGhlYWx0aF9jaGVjaygpOgogICAgcmV0dXJuIHsic3RhdHVzIjogIk9LIiwgIm1lc3NhZ2UiOiAiQXBwIHNlcnZlciJ9CgppZiBfX25hbWVfXyA9PSAiX19tYWluX18iOgogICAgdXZpY29ybi5ydW4oYXBwLCBob3N0PSIwLjAuMC4wIiwgcG9ydD04MDAwKQ==" | base64 -d > /home/ec2-user/app/app.py
    chown -R ec2-user:ec2-user /home/ec2-user/app
    
    cat > /etc/systemd/system/app-server.service << 'EOF'
[Unit]
Description=App Server
After=network.target

[Service]
Type=exec
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/python3 /home/ec2-user/app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable app-server
    systemctl start app-server
fi
