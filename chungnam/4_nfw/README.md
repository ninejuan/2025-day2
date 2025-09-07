# Network Firewall Infrastructure

이 프로젝트는 AWS Network Firewall을 사용하여 VPC 간 네트워크 트래픽 제어를 구현합니다.

## 아키텍처 개요

### VPC 구조
- **Egress VPC (10.0.0.0/16)**: 인터넷 연결 및 방화벽 처리를 담당
  - Public Subnets: 10.0.0.0/24, 10.0.1.0/24
  - Peering Subnets: 10.0.2.0/24, 10.0.3.0/24
  - Firewall Subnets: 10.0.4.0/24, 10.0.5.0/24

- **App VPC (172.16.0.0/16)**: 애플리케이션 워크로드를 호스팅
  - Private Subnets: 172.16.0.0/24, 172.16.1.0/24

### Network Firewall 보안 정책

#### Stateless 규칙
- **ICMP 차단**: 모든 ICMP(ping) 프로토콜 트래픽을 차단하여 네트워크 스캐닝 방지

#### Stateful 규칙
- **외부 DNS 쿼리 차단**: UDP/TCP 53 포트를 사용하는 모든 외부 DNS 쿼리 차단
- **직접 IP 접근 차단**: IP 직접 접속 차단
- **DNS over HTTPS 차단**: 주요 DoH 서비스 (Cloudflare, Google, Quad9) 차단

### 주요 구성 요소

1. **VPC Peering**: App VPC와 Egress VPC 간 통신
2. **Network Firewall**: Egress VPC의 Firewall 서브넷에 배치
3. **Bastion Host**: App VPC의 Private 서브넷에 배치, Systems Manager 접근 가능
4. **Route Tables**: 트래픽이 방화벽을 통과하도록 구성

## 배포 방법

### 1. 사전 요구사항
- AWS CLI 구성
- Terraform >= 1.0
- 적절한 AWS IAM 권한

### 2. 배포 단계

```bash
# 1. SSH 키 페어 생성 (이미 완료됨)
ssh-keygen -t rsa -b 2048 -f nfw-key -N ""

# 2. Terraform 초기화
terraform init

# 3. 설정 확인
terraform plan

# 4. 인프라 배포
terraform apply
```

### 3. 설정 파일
- `terraform.tfvars`: 배포 환경에 맞게 수정 가능
- 기본 리전: eu-west-1

## 테스트 방법

### Bastion Host 접근
```bash
# Systems Manager를 통한 접근 (권장)
aws ssm start-session --target <instance-id> --region eu-west-1

# SSH를 통한 접근 (VPC Peering 경유)
ssh -i nfw-key ec2-user@<private-ip>
```

### 방화벽 규칙 테스트
```bash
# ICMP 테스트 (차단되어야 함)
ping 8.8.8.8

# DNS 쿼리 테스트 (차단되어야 함)
nslookup google.com 8.8.8.8

# 일반 HTTP/HTTPS 트래픽 (허용되어야 함)
curl -I http://example.com
```

## 리소스 정리

```bash
terraform destroy
```

## 주의사항

- Network Firewall 배포에는 몇 분이 소요될 수 있습니다
- Bastion Host는 Systems Manager 접근이 가능해야 채점에 문제가 없습니다
- 모든 리소스는 eu-west-1 리전에 배포됩니다

## 아키텍처 다이어그램

```
Internet
    |
    v
[Internet Gateway]
    |
    v
[Public Subnets] -----> [NAT Gateways]
    |                        |
    v                        v
[Firewall Subnets] <--> [Network Firewall]
    |
    v
[Peering Subnets]
    |
    v
[VPC Peering Connection]
    |
    v
[App VPC Private Subnets] ---> [Bastion Host]
```
