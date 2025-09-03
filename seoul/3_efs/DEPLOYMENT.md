# EFS 보안 접근 인프라 배포 가이드

## 사전 준비

### 1. AWS 자격 증명 설정
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-west-1"
```

### 2. SSH 키 페어 생성
```bash
chmod +x generate-ssh-keys.sh
./generate-ssh-keys.sh
```

### 3. 변수 파일 설정
```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일에서 student_number 값을 실제 선수 등번호로 변경
```

## 배포 단계

### 1. Terraform 초기화
```bash
terraform init
```

### 2. 배포 계획 확인
```bash
terraform plan
```

### 3. 인프라 배포
```bash
terraform apply
```

### 4. 출력값 확인
```bash
terraform output
```

## EFS 마운트 및 테스트

### 1. Bastion 호스트에서 App 인스턴스 접속
```bash
# Bastion 호스트에 SSH 접속
ssh -i modules/ec2/ssh-key ec2-user@<bastion-public-ip>

# App 1 인스턴스에 SSH 접속
ssh -i modules/ec2/ssh-key ec2-user@10.128.128.199

# App 2 인스턴스에 SSH 접속
ssh -i modules/ec2/ssh-key ec2-user@10.128.144.199
```

### 2. EFS 마운트
```bash
# App 인스턴스에서 실행
chmod +x efs-mount.sh
./efs-mount.sh <student_number> <efs_file_system_id> <efs_access_point_id>
```

### 3. 자동 마운트 설정
```bash
# App 인스턴스에서 실행
chmod +x efs-fstab.sh
./efs-fstab.sh <student_number> <efs_file_system_id> <efs_access_point_id>
```

## 검증 방법

### 1. EFS 접근 권한 확인
- App 인스턴스에서 EFS 마운트 성공
- Bastion 호스트에서 EFS 마운트 실패 (정책상 차단)

### 2. 보안 정책 확인
- IP 기반 접근 제어 (App 인스턴스 IP만 허용)
- 태그 기반 권한 (AppRole: wsi-app 태그 필요)
- 시간 제한 (2025년 9월 20일 ~ 26일)

### 3. 암호화 확인
- KMS 키를 사용한 EFS 암호화
- TLS를 통한 전송 암호화

## 문제 해결

### 1. EFS 마운트 실패
```bash
# EFS 클라이언트 설치 확인
sudo yum install -y amazon-efs-utils

# 보안 그룹 설정 확인
aws ec2 describe-security-groups --group-ids <security-group-id>

# IAM 역할 권한 확인
aws iam get-role --role-name wsi-ec2-efs-role
```

### 2. KMS 권한 문제
```bash
# KMS 키 정책 확인
aws kms get-key-policy --key-id <kms-key-id> --policy-name default

# IAM 역할에 KMS 권한 추가
aws iam attach-role-policy --role-name wsi-ec2-efs-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonElasticFileSystemClientFullAccess
```

## 정리

### 1. 인프라 삭제
```bash
terraform destroy
```

### 2. SSH 키 정리
```bash
rm -f modules/ec2/ssh-key*
```
