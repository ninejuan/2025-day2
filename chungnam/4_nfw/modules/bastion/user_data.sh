#!/bin/bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

snap install amazon-ssm-agent --classic || true
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || true

apt-get install -y curl wget netcat-openbsd dnsutils

systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service || true
systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service > /var/log/ssm-status.log 2>&1
