# NoSQL Database - 실시간 글로벌 계좌 송금 시스템

이 모듈은 DynamoDB Global Table과 Lambda를 사용하여 실시간 글로벌 계좌 송금 시스템을 구성합니다.

## 아키텍처 개요

- **DynamoDB Global Table**: ap-northeast-2와 eu-central-1 두 리전 간 실시간 동기화
- **Lambda**: 동기화 충돌 해결을 위한 Conflict Resolution 함수
- **EC2**: Flask 애플리케이션 호스팅 (계좌 생성, 송금 API 제공)
- **Bastion**: EC2 인스턴스 접근을 위한 점프 서버
- **PITR**: Point-in-Time Recovery 활성화

## 구성 요소

### 1. DynamoDB Global Table
- **테이블명**: `account-table`
- **Primary Key**: `account_id` (String)
- **리전**: ap-northeast-2 (Primary), eu-central-1 (Replica)
- **PITR**: 활성화됨
- **암호화**: 서버 사이드 암호화 활성화
- **스트림**: NEW_AND_OLD_IMAGES 활성화

### 2. Lambda 함수
- **함수명**: `account-conflict-resolver`
- **역할**: 동기화 충돌 자동 해결
- **트리거**: DynamoDB Stream 이벤트

### 3. EC2 인스턴스
- **인스턴스명**: `account-app-ec2`
- **인스턴스 타입**: t3.micro
- **애플리케이션**: Flask 기반 계좌 관리 API
- **포트**: 8080

### 4. Bastion 호스트
- **역할**: EC2 인스턴스 접근을 위한 점프 서버
- **포트**: 22 (SSH), 80 (상태 페이지)

## API 엔드포인트

### 1. 계좌 생성
```bash
POST /create_account
Content-Type: application/json

{
    "account_id": "cloud",
    "balance": 1000,
    "currency": "USD"
}
```

### 2. 송금
```bash
POST /transfer
Content-Type: application/json

{
    "from_account": "cloud",
    "to_account": "it",
    "amount": 500
}
```

### 3. 계좌 조회
```bash
GET /account/{account_id}
```

### 4. 계좌 목록
```bash
GET /accounts
```

### 5. 헬스 체크
```bash
GET /healthcheck
```

## 배포 방법

### 1. 사전 요구사항
- AWS CLI 구성
- Terraform 설치
- SSH 키 생성

### 2. SSH 키 생성
```bash
ssh-keygen -t rsa -b 4096 -f nosql-key -N "" -C "nosql-bastion-key"
```

### 3. Terraform 변수 설정
```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일을 편집하여 필요한 값 설정
```

### 4. 인프라 배포
```bash
terraform init
terraform plan
terraform apply
```

### 5. 배포 확인
```bash
# Bastion 접속
ssh -i nosql-key ec2-user@<bastion-public-ip>

# EC2 인스턴스 접속 (Bastion을 통해)
ssh -i nosql-key ec2-user@<ec2-private-ip>

# 서비스 상태 확인
sudo systemctl status account-app
```

## 테스트 방법

### 1. API 테스트
```bash
# 헬스 체크
curl http://<ec2-public-ip>:8080/healthcheck

# 계좌 생성
curl -X POST http://<ec2-public-ip>:8080/create_account \
  -H "Content-Type: application/json" \
  -d '{"account_id": "test-account", "balance": 1000, "currency": "USD"}'

# 송금 테스트
curl -X POST http://<ec2-public-ip>:8080/transfer \
  -H "Content-Type: application/json" \
  -d '{"from_account": "test-account", "to_account": "target-account", "amount": 100}'
```

### 2. DynamoDB 테스트
```bash
# Bastion에서 DynamoDB 테스트 실행
cd /opt/dynamodb-test
python3 test_dynamodb.py
```

## 모니터링

### 1. 서비스 모니터링
```bash
# Bastion에서 모니터링 스크립트 실행
cd /opt/dynamodb-test
./monitor.sh
```

### 2. CloudWatch 메트릭
- DynamoDB: 읽기/쓰기 용량, 지연 시간
- Lambda: 실행 횟수, 오류율, 지연 시간
- EC2: CPU, 메모리, 네트워크

### 3. 로그 확인
```bash
# 애플리케이션 로그
journalctl -u account-app -f

# 시스템 로그
tail -f /var/log/account-setup.log
```

## 보안 고려사항

1. **네트워크 보안**
   - EC2 인스턴스는 Bastion을 통해서만 접근 가능
   - API는 공개적으로 접근 가능 (포트 8080)

2. **IAM 권한**
   - 최소 권한 원칙 적용
   - DynamoDB 접근 권한만 부여

3. **암호화**
   - DynamoDB 서버 사이드 암호화
   - EBS 볼륨 암호화

## 트러블슈팅

### 1. 서비스 시작 실패
```bash
# 서비스 상태 확인
sudo systemctl status account-app

# 로그 확인
journalctl -u account-app --no-pager -n 50
```

### 2. DynamoDB 연결 오류
```bash
# AWS 자격 증명 확인
aws sts get-caller-identity

# DynamoDB 테이블 확인
aws dynamodb describe-table --table-name account-table
```

### 3. Lambda 함수 오류
```bash
# CloudWatch 로그 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/account-conflict-resolver"
```

## 비용 최적화

1. **DynamoDB**: On-Demand 모드 사용
2. **EC2**: t3.micro 인스턴스 사용
3. **Lambda**: 필요시에만 실행
4. **CloudWatch**: 로그 보존 기간 설정

## 확장성

1. **수평 확장**: DynamoDB는 자동으로 확장
2. **지역 확장**: 추가 리전에 Global Table 복제본 추가 가능
3. **애플리케이션 확장**: ALB와 Auto Scaling Group 추가 가능
