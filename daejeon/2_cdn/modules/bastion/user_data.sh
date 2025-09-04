#!/bin/bash

dnf update -y
dnf install -y awscli2 curl wget git htop vim unzip python3-pip
pip3 install boto3
