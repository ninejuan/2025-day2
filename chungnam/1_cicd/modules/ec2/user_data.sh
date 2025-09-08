#!/bin/bash
set -e

yum update -y

yum install -y docker
systemctl start docker
systemctl enable docker

usermod -aG docker ec2-user

cd /home/ec2-user
mkdir actions-runner && cd actions-runner

RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep 'tag_name' | cut -d'"' -f4 | cut -c2-)
curl -o actions-runner-linux-x64-$RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz

tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz

chown -R ec2-user:ec2-user /home/ec2-user/actions-runner

cat > /home/ec2-user/configure-runner.sh << 'EOF'
#!/bin/bash
cd /home/ec2-user/actions-runner

REGISTRATION_TOKEN=$(curl -X POST -H "Authorization: token ${github_token}" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/${github_repo}/actions/runners/registration-token" | jq -r .token)

./config.sh --url "https://github.com/${github_repo}" --token "$REGISTRATION_TOKEN" --name "wsc2025-runner" --work "_work" --labels "self-hosted,linux,x64" --unattended

sudo ./svc.sh install
sudo ./svc.sh start
EOF

chmod +x /home/ec2-user/configure-runner.sh
chown ec2-user:ec2-user /home/ec2-user/configure-runner.sh

yum install -y jq

echo "Runner setup completed. Run /home/ec2-user/configure-runner.sh to configure the runner."
