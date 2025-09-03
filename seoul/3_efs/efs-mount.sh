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

echo "EFS 마운트 시작..."
echo "학생 번호: $STUDENT_NUMBER"
echo "EFS 파일 시스템 ID: $EFS_FILE_SYSTEM_ID"
echo "EFS 액세스 포인트 ID: $EFS_ACCESS_POINT_ID"

sudo mkdir -p /mnt/efs
echo "EFS 마운트 중..."
sudo mount -t efs -o tls,accesspoint=$EFS_ACCESS_POINT_ID $EFS_FILE_SYSTEM_ID:/ /mnt/efs

if mountpoint -q /mnt/efs; then
    echo "EFS 마운트 성공!"
    
    TEST_FILE="/mnt/efs/hello-${STUDENT_NUMBER}.txt"
    if [ ! -f "$TEST_FILE" ]; then
        echo "테스트 파일 생성 중: $TEST_FILE"
        echo "Hello from WorldSkills" | sudo tee "$TEST_FILE"
        echo "테스트 파일 생성 완료!"
    else
        echo "테스트 파일이 이미 존재합니다: $TEST_FILE"
    fi
    
    echo "생성된 파일 내용:"
    sudo cat "$TEST_FILE"
    
    echo ""
    echo "마운트 정보:"
    df -h /mnt/efs
    mount | grep efs
    
else
    echo "EFS 마운트 실패!"
    exit 1
fi

echo "EFS 마운트 및 테스트 완료!"
