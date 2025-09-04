# CloudWatch Monitoring System

이 프로젝트는 AWS ECS와 CloudWatch를 사용하여 애플리케이션의 상태를 모니터링하는 시스템입니다.

## 아키텍처

- **VPC**: 10.0.0.0/16 CIDR 블록을 사용하는 멀티 AZ 구성
- **ECS**: Fargate 기반 컨테이너 오케스트레이션
- **ALB**: 애플리케이션 로드 밸런서
- **Bastion**: 프라이빗 서브넷 접근을 위한 점프 호스트
- **CloudWatch**: 모니터링 및 알림

## 애플리케이션 엔드포인트

- `GET /hello` - Hello World 응답
- `GET /healthcheck` - 헬스 체크
- `GET /test_latency` - 지연 시간 테스트
- `GET /latency_stats` - 지연 시간 통계

## 배포 방법

1. **전제 조건**
   - AWS CLI 구성
   - Docker 설치
   - Terraform 설치

2. **배포 실행**
   ```bash
   ./deploy.sh
   ```

3. **수동 배포**
   ```bash
   # Terraform 초기화
   terraform init
   
   # 계획 확인
   terraform plan
   
   # 배포 실행 (Docker 이미지 빌드 및 푸시 자동화됨)
   terraform apply
   ```

## 모니터링

### CloudWatch Dashboard
- **wsi-success**: 성공 요청 수 모니터링
- **wsi-fail**: 실패 요청 수 모니터링  
- **wsi-sli**: 시스템 가용성 SLI (Gauge)
- **wsi-p90-p95-p99**: 지연 시간 백분위수 모니터링

### CloudWatch Alarms
- **High Error Rate**: 5xx 에러율 모니터링
- **High Response Time**: 응답 시간 모니터링

## 접근 방법

### 애플리케이션 접근
```bash
# ALB DNS 이름 확인
terraform output alb_dns_name

# 애플리케이션 테스트
curl http://<ALB_DNS>/healthcheck
curl http://<ALB_DNS>/hello
curl http://<ALB_DNS>/test_latency
curl http://<ALB_DNS>/latency_stats
```

### Bastion 호스트 접근
```bash
# Bastion IP 확인
terraform output bastion_public_ip

# SSH 접근
ssh -i wsi-keypair ec2-user@<BASTION_IP>
```

### CloudWatch Dashboard 접근
```bash
# Dashboard URL 확인
terraform output cloudwatch_dashboard_url
```

## 정리

```bash
terraform destroy
```

## 파일 구조

```
.
├── main.tf                 # 메인 Terraform 구성
├── outputs.tf              # 출력 값 정의
├── deploy.sh               # 배포 스크립트
├── wsi-keypair.pub         # SSH 공개 키
├── app-files/
│   ├── app.py              # Flask 애플리케이션
│   └── Dockerfile          # 컨테이너 이미지 정의
└── modules/
    ├── vpc/                # VPC 모듈
    ├── ecr/                # ECR 모듈 (자동 Docker 빌드/푸시)
    ├── bastion/            # Bastion 모듈
    ├── alb/                # ALB 모듈
    ├── ecs/                # ECS 모듈
    └── cloudwatch/         # CloudWatch 모듈
```
