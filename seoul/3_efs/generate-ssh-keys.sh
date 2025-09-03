#!/bin/bash
set -e

echo "SSH 키 페어 생성 시작..."

KEY_DIR="modules/ec2"
KEY_NAME="ssh-key"

mkdir -p "$KEY_DIR"

if [ ! -f "$KEY_DIR/$KEY_NAME" ]; then
    echo "SSH 키 페어 생성 중..."
    ssh-keygen -t rsa -b 4096 -f "$KEY_DIR/$KEY_NAME" -N "" -C "efs-bastion-key"
    echo "SSH 키 페어 생성 완료!"
else
    echo "SSH 키 페어가 이미 존재합니다."
fi

chmod 600 "$KEY_DIR/$KEY_NAME"
chmod 644 "$KEY_DIR/$KEY_NAME.pub"

echo ""
echo "생성된 키 파일:"
echo "  Private Key: $KEY_DIR/$KEY_NAME"
echo "  Public Key:  $KEY_DIR/$KEY_NAME.pub"
echo ""
echo "Public Key 내용:"
cat "$KEY_DIR/$KEY_NAME.pub"

echo ""
echo "SSH 키 페어 생성 완료!"
