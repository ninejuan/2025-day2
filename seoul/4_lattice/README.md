# VPC Lattice 보안 접근 인프라

이 프로젝트는 AWS VPC Lattice를 사용하여 Private 마이크로서비스 아키텍처를 구성합니다.

## 🏗️ 모듈화된 아키텍처

이 프로젝트는 재사용 가능한 Terraform 모듈들로 구성되어 있습니다:

### 📦 **모듈 구조**
```
modules/
├── vpc/              # VPC, 서브넷, 라우팅 테이블
├── ec2/              # EC2 인스턴스 및 EIP
│   ├── userdata/     # 사용자 데이터 스크립트
│   └── keys/         # SSH 키 파일
├── security_group/   # 보안 그룹
├── iam/              # IAM 역할 및 정책
└── lattice/          # VPC Lattice 리소스
```

### 🔧 **모듈별 기능**
- **VPC 모듈**: VPC, 서브넷, 인터넷 게이트웨이, NAT 게이트웨이, 라우팅 테이블
- **EC2 모듈**: EC2 인스턴스, Elastic IP, 사용자 데이터 템플릿, SSH 키 관리
- **보안 그룹 모듈**: 동적 인바운드/아웃바운드 규칙 지원
- **IAM 모듈**: IAM 역할, 인스턴스 프로필, 관리형/인라인 정책
- **Lattice 모듈**: VPC Lattice 서비스 네트워크, 서비스, 타겟 그룹

## 🏛️ 아키텍처 개요

- **VPC A**: Public/Private 서브넷 구성 (10.1.0.0/16)
- **VPC B**: Public/Private 서브넷 구성 (10.2.0.0/16)
- **Bastion Host**: VPC A의 Public 서브넷에 위치
- **Service A**: VPC A의 Private 서브넷에 위치한 Flask 애플리케이션
- **Service B**: VPC B의 Private 서브넷에 위치한 Flask + DynamoDB 애플리케이션
- **VPC Lattice**: 서비스 간 통신을 위한 네트워킹 레이어

## 🧩 구성 요소

### 1. VPC 구성
- **VPC A**: 10.1.0.0/16 (ap-southeast-1a)
  - Public 서브넷: 10.1.1.0/24
  - Private 서브넷: 10.1.2.0/24
- **VPC B**: 10.2.0.0/16 (ap-southeast-1b)
  - Public 서브넷: 10.2.1.0/24
  - Private 서브넷: 10.2.2.0/24

### 2. EC2 인스턴스
- **Bastion Host**: t3.micro, AdministratorAccess 정책
- **Service A**: t3.micro, Flask 애플리케이션
- **Service B**: t3.micro, Flask + DynamoDB 애플리케이션

### 3. DynamoDB
- **테이블명**: service-b-table
- **Partition Key**: id (String)

### 4. VPC Lattice
- **서비스 네트워크**: lattice-net
- **서비스**: service-b-lattice
- **Target Group**: service-b-tg

## 🚀 배포 방법

### 1. 사전 요구사항
- AWS CLI 설정
- Terraform 설치 (>= 1.0)
- 적절한 AWS 권한

### 2. 배포 단계
```bash
# Terraform 초기화
terraform init

# 계획 확인
terraform plan

# 인프라 배포
terraform apply

# 출력 확인
terraform output
```

### 3. 접속 방법
```bash
# Bastion Host 접속
ssh -i bastion-key ec2-user@<bastion-public-ip>

# Service A 접속 (Bastion을 통해)
ssh -i bastion-key ec2-user@<service-a-private-ip>

# Service B 접속 (Bastion을 통해)
ssh -i bastion-key ec2-user@<service-b-private-ip>
```

## 🧪 서비스 테스트

### Service A 테스트
```bash
# Bastion에서 Service A 테스트
curl http://<service-a-private-ip>/hello
```

### Service B 테스트
```bash
# Bastion에서 Service B 테스트
curl http://<service-b-private-ip>/api
curl http://<service-b-private-ip>/api/get
```

### VPC Lattice 테스트
```bash
# Service A에서 Service B 호출 (VPC Lattice를 통해)
curl http://service-b-lattice.lattice-net/api
```

## 🔒 보안 구성

- 모든 Private 서브넷은 Bastion Host를 통해서만 접근 가능
- VPC Lattice를 통한 서비스 간 통신
- IAM 역할 기반 권한 관리
- 보안 그룹을 통한 네트워크 접근 제어

## 🧹 정리

```bash
# 인프라 정리
terraform destroy
```

## 📋 모듈 재사용

이 프로젝트의 모듈들은 다른 프로젝트에서도 재사용할 수 있습니다:

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"
  # ... 기타 변수들
}

module "ec2" {
  source = "./modules/ec2"
  
  ami_id = "ami-12345"
  instance_type = "t3.micro"
  # ... 기타 변수들
}
```

## ⚠️ 주의사항

- 이 프로젝트는 싱가포르(ap-southeast-1) 리전에서 실행됩니다
- Bastion Host는 AdministratorAccess 정책을 사용합니다
- 모든 서비스는 Private 서브넷에 위치하여 외부 직접 접근이 차단됩니다
- 모듈들은 독립적으로 테스트하고 배포할 수 있습니다

## 🔄 모듈 업데이트

모듈을 수정한 후에는 다음 명령어로 테스트할 수 있습니다:

```bash
# 특정 모듈만 계획 확인
terraform plan -target=module.vpc_a
terraform plan -target=module.ec2

# 특정 모듈만 적용
terraform apply -target=module.vpc_a
```
