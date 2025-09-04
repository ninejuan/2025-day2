# WAF XXE Protection Project

이 프로젝트는 AWS WAF를 사용하여 XXE(XML External Entity) 공격을 방어하는 시스템을 구성합니다.

## 개요

- **리전**: us-west-1
- **VPC**: Default VPC 사용
- **목적**: XXE 공격 방어를 위한 WAF 구성

## 아키텍처

```
Internet → WAF → ALB → EC2 (XXE Server)
                ↓
            Bastion Host
```

## 구성 요소

### 1. EC2 인스턴스 (xxe-server)
- **인스턴스 타입**: t3.micro
- **역할**: XXE 취약한 Flask 애플리케이션 실행
- **포트**: 5000 (Flask 애플리케이션)

### 2. Application Load Balancer (xxe-alb)
- **타입**: Application Load Balancer
- **역할**: 인터넷에서 EC2 인스턴스로의 트래픽 라우팅
- **포트**: 80 (HTTP)

### 3. WAF (xxe-waf)
- **역할**: XXE 공격 패턴 차단
- **규칙**: 단일 규칙으로 비용 최적화
- **응답**: 403 Forbidden error

### 4. Bastion Host
- **역할**: EC2 인스턴스에 대한 SSH 접근 제공
- **보안**: SSH 키 기반 인증

## XXE 공격 방어 패턴

WAF는 다음 패턴들을 차단합니다:

1. `<!DOCTYPE` - DTD 선언
2. `<!ENTITY` - 엔티티 선언
3. `&` - 엔티티 참조
4. `file://` - 로컬 파일 접근
5. `http://169.254.169.254` - AWS 메타데이터 서비스 접근
6. `SYSTEM` - 시스템 엔티티
7. `PUBLIC` - 공개 엔티티

## 애플리케이션

### 엔드포인트

| Path | Method | 설명 |
|------|--------|------|
| `/` | GET | XML 업로드 폼 |
| `/parse` | POST | XML 파싱 (XXE 취약) |

### 예시 요청

```bash
# 정상 XML
curl -X POST http://ALB_DNS/parse \
  -d "xml=<note><msg>Hi</msg></note>"

# XXE 공격 (차단됨)
curl -X POST http://ALB_DNS/parse \
  -d "xml=<!DOCTYPE test [<!ENTITY xxe SYSTEM 'file:///etc/passwd'>]><test>&xxe;</test>"
```

## 배포 방법

### 1. 사전 요구사항
- AWS CLI 구성
- Terraform 설치
- SSH 키 생성 (이미 생성됨)

### 2. 배포
```bash
# Terraform 초기화
terraform init

# 계획 확인
terraform plan

# 배포
terraform apply
```

### 3. 접근 방법

#### 애플리케이션 접근
```bash
# ALB DNS 이름 확인
terraform output alb_dns_name

# 애플리케이션 접근
curl http://ALB_DNS_NAME
```

#### Bastion을 통한 EC2 접근
```bash
# Bastion 접속
ssh -i waf-key ec2-user@$(terraform output -raw bastion_public_ip)

# Bastion에서 EC2 접속
ssh -i waf-key ec2-user@$(terraform output -raw xxe_server_private_ip)
```

## 테스트 방법

### 1. 정상 요청 테스트
```bash
curl -X POST http://ALB_DNS/parse \
  -d "xml=<note><msg>Hello World</msg></note>"
```

### 2. XXE 공격 테스트
```bash
# 파일 읽기 공격
curl -X POST http://ALB_DNS/parse \
  -d "xml=<!DOCTYPE test [<!ENTITY xxe SYSTEM 'file:///etc/passwd'>]><test>&xxe;</test>"

# AWS 메타데이터 공격
curl -X POST http://ALB_DNS/parse \
  -d "xml=<!DOCTYPE test [<!ENTITY xxe SYSTEM 'http://169.254.169.254/latest/meta-data/'>]><test>&xxe;</test>"
```

예상 결과: `403 Forbidden error`

## 모니터링

- CloudWatch 메트릭을 통해 WAF 차단 이벤트 모니터링 가능
- WAF 로그를 통해 공격 패턴 분석 가능

## 정리

```bash
terraform destroy
```

## 보안 고려사항

1. **WAF 규칙**: XXE 공격 패턴을 효과적으로 차단
2. **네트워크 보안**: Bastion을 통한 접근 제어
3. **암호화**: EBS 볼륨 암호화 적용
4. **IAM**: 최소 권한 원칙 적용

## 비용 최적화

- WAF 규칙을 단일 규칙으로 구성하여 비용 절약
- t3.micro 인스턴스 사용
- Default VPC 사용으로 VPC 비용 절약
