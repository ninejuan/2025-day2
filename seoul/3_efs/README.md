# EFS 보안 접근 인프라

이 프로젝트는 AWS EFS(Elastic File System)에 대한 보안 접근을 제어하는 인프라를 구성합니다.

## 구성 요소

### 1. VPC
- **VPC Name**: efs-vpc
- **VPC CIDR**: 10.128.0.0/16
- **서브넷**:
  - efs-pub-b: 10.128.0.0/20 (Public)
  - efs-pub-c: 10.128.16.0/20 (Public)
  - efs-app-b: 10.128.128.0/20 (Private)
  - efs-app-c: 10.128.144.0/20 (Private)

### 2. IAM
- **역할**: wsi-ec2-efs-role
- **권한**: EFS 읽기/쓰기 (최소 권한 원칙)

### 3. EC2 인스턴스
- **Bastion Host**: efs-bastion (10.128.0.199)
- **App 1**: efs-app-1 (10.128.128.199)
- **App 2**: efs-app-2 (10.128.144.199)

### 4. KMS
- **키 별칭**: wsi-kms
- **용도**: EFS 암호화 및 IAM 역할 권한

### 5. EFS
- **파일 시스템**: wsi-efs-fs
- **액세스 포인트**: wsi-efs-ap
- **루트 경로**: /app/wsi{선수등번호}
- **보안**: IP 기반 접근 제어, 태그 기반 권한, 시간 제한

## 사용법

### 1. 변수 설정
```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일에서 student_number 값을 실제 선수 등번호로 변경
```

### 2. Terraform 실행
```bash
terraform init
terraform plan
terraform apply
```

### 3. EFS 마운트 (App 인스턴스에서)
```bash
# EFS 마운트
sudo mount -t efs -o tls,accesspoint=<access-point-id> <file-system-id>:/ /mnt/efs

# 테스트 파일 생성
echo "Hello from WorldSkills" | sudo tee /mnt/efs/hello-{선수등번호}.txt
```

## 보안 특징

1. **IP 기반 접근 제어**: App 인스턴스 IP만 허용
2. **태그 기반 권한**: AppRole: wsi-app 태그 필요
3. **시간 제한**: 2025년 9월 20일 UTC 3:00 ~ 9월 26일 UTC 18:00
4. **Bastion 접근 차단**: 명시적으로 Bastion IP에서의 접근 차단
5. **전송 암호화**: TLS 강제

## 주의사항

- Bastion 호스트와 App 인스턴스는 채점에 사용되므로 접근 권한 문제가 없어야 함
- sshpass 라이브러리 설치 필요: `sudo yum install -y sshpass`
- 인스턴스 재시작 시에도 IP 변경되지 않도록 고정 IP 설정
