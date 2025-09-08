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
    
    docker pull $ECR_REPO_URL:latest || echo "ECR image not found, will build locally"
    
    if docker image inspect $ECR_REPO_URL:latest > /dev/null 2>&1; then
        docker run -d --name app-server -p 8000:8000 --restart always $ECR_REPO_URL:latest
    else
        echo "Running fallback app server with provided app files"
        yum install -y python3 python3-pip git
        
        mkdir -p /home/ec2-user/app-files
        
        cat > /home/ec2-user/app-files/app.py << 'APPEOF'
${app_py_content}
APPEOF
        
        cat > /home/ec2-user/app-files/requirements.txt << 'REQEOF'
${requirements_content}
REQEOF
        
        chown -R ec2-user:ec2-user /home/ec2-user/app-files
        
        cd /home/ec2-user/app-files
        pip3 install -r requirements.txt
        
        cat > /etc/systemd/system/app-server.service << SVCEOF
[Unit]
Description=App Server
After=network.target

[Service]
Type=exec
User=ec2-user
WorkingDirectory=/home/ec2-user/app-files
ExecStart=/usr/bin/python3 /home/ec2-user/app-files/app.py
Restart=always

[Install]
WantedBy=multi-user.target
SVCEOF

        systemctl daemon-reload
        systemctl enable app-server
        systemctl start app-server
    fi
else
    echo "No ECR repository URL provided, running with provided app files"
    yum install -y python3 python3-pip git
    
    mkdir -p /home/ec2-user/app-files
    
    cat > /home/ec2-user/app-files/app.py << 'APPEOF'
${app_py_content}
APPEOF
    
    cat > /home/ec2-user/app-files/requirements.txt << 'REQEOF'
${requirements_content}
REQEOF
    
    chown -R ec2-user:ec2-user /home/ec2-user/app-files
    
    cd /home/ec2-user/app-files
    pip3 install -r requirements.txt
    
    cat > /etc/systemd/system/app-server.service << SVCEOF
[Unit]
Description=App Server
After=network.target

[Service]
Type=exec
User=ec2-user
WorkingDirectory=/home/ec2-user/app-files
ExecStart=/usr/bin/python3 /home/ec2-user/app-files/app.py
Restart=always

[Install]
WantedBy=multi-user.target
SVCEOF

    systemctl daemon-reload
    systemctl enable app-server
    systemctl start app-server
fi
