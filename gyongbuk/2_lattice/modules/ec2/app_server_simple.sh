#!/bin/bash
yum update -y
yum install -y docker git

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
        echo "Running fallback - installing Python app"
        yum install -y python3 python3-pip
        pip3 install flask boto3 fastapi uvicorn pydantic
        
        mkdir -p /home/ec2-user/app
        echo "${app_py_content}" | base64 -d > /home/ec2-user/app/app.py
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
    echo "No ECR URL - installing Python app"
    yum install -y python3 python3-pip
    pip3 install flask boto3 fastapi uvicorn pydantic
    
    mkdir -p /home/ec2-user/app
    echo "${app_py_content}" | base64 -d > /home/ec2-user/app/app.py
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
