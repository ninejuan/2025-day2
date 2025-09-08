#!/bin/bash

yum update -y

yum install -y awscli2 curl jq

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

aws configure set region ${region}
