#!/bin/bash
set -e

STUDENT_NUMBER="${1:-12345}"
EFS_FILE_SYSTEM_ID="${2}"
EFS_ACCESS_POINT_ID="${3}"

if [ -z "$EFS_FILE_SYSTEM_ID" ] || [ -z "$EFS_ACCESS_POINT_ID" ]; then
    echo "Usage: $0 <student_number> <efs_file_system_id> <efs_access_point_id>"
    echo "Example: $0 12345 fs-12345678 fsap-12345678"
    exit 1
fi

echo "EFS 자동 마운트 설정 시작..."
echo "학생 번호: $STUDENT_NUMBER"
echo "EFS 파일 시스템 ID: $EFS_FILE_SYSTEM_ID"
echo "EFS 액세스 포인트 ID: $EFS_ACCESS_POINT_ID"

sudo cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)

FSTAB_ENTRY="${EFS_FILE_SYSTEM_ID}:/ /mnt/efs efs _netdev,tls,accesspoint=${EFS_ACCESS_POINT_ID} 0 0"

if ! grep -q "/mnt/efs" /etc/fstab; then
    echo "fstab에 EFS 마운트 항목 추가 중..."
    echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
    echo "fstab 업데이트 완료!"
    
    echo ""
    echo "현재 fstab 내용:"
    cat /etc/fstab | grep -E "(efs|/mnt/efs)"
    
else
    echo "fstab에 이미 EFS 마운트 항목이 존재합니다."
fi

echo "EFS 자동 마운트 설정 완료!"
echo "재부팅 후 자동으로 마운트됩니다."
