# GAC Competition Day2 - CICD 인프라 구성

이 프로젝트는 전국기능경기대회 2과제의 CI/CD 인프라를 Terraform으로 구성한 것입니다.

## 구성 요소

### 1. VPC (gac-vpc)
- Public/Private 서브넷 2쌍 구성
- NAT Gateway를 통한 Private 서브넷 인터넷 접근
- EKS 클러스터용 태그 설정

### 2. KMS (gac-key)
- ECR 및 EKS 암호화용 키
- 즉시 삭제 설정 (복구 기간 없음)

### 3. ECR (gac-app)
- KMS 암호화 적용
- IMMUTABLE 태그 정책으로 중복 업로드 방지
- 생명주기 정책으로 이미지 관리

### 4. EKS (gac-eks-cluster)
- Private 서브넷에 배치
- EC2 Worker Node 사용
- KMS 암호화 적용

### 5. Bastion 호스트
- AdministratorAccess 및 AmazonSSMManagedInstanceCore 권한
- jq, curl, kubectl, awscli, github cli 설치
- Public 서브넷에 배치

### 6. Github Actions Runner
- Self-Hosted runner 인스턴스
- ECR 및 EKS 접근 권한
- Docker, kubectl, awscli, github cli 설치

### 7. ArgoCD
- EKS 클러스터에 설치
- gac-gitops 레포지토리 연동
- 자동 동기화 및 자가 치유 설정

## 사용법

### 1. 사전 준비
```bash
# AWS CLI 설정
aws configure

# Terraform 설치 확인
terraform version

# 키페어 생성
aws ec2 create-key-pair --key-name gac-key --query 'KeyMaterial' --output text > gac-key.pem
chmod 400 gac-key.pem
```

### 2. 변수 설정
```bash
# terraform.tfvars.example을 복사하여 수정
cp terraform.tfvars.example terraform.tfvars

# 필요한 값들을 수정
vim terraform.tfvars
```

### 3. 인프라 배포
```bash
# 초기화
terraform init

# 계획 확인
terraform plan

# 배포
terraform apply
```

### 4. ArgoCD 접속
```bash
# Change password
# argocd가 준비된 후, 아래 명령어를 통해 argocd 비밀번호를 변경합니다.

#kubectl exec -it -n argocd deployment/argocd-server -- /bin/bash
#argocd login localhost:8080
#argocd account update-password

# 포트 포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 5. Github Setting
```sh
# Bastion Host에 아래 명령어를 통해 Github 로그인합니다.
gh auth login

# gac-app, gac-gitops를 Github에 Push합니다.
# 그 후, Github Runner 인스턴스를 등록하고, Secrets를 아래와 같이 세팅합니다. (Secrets and variables -> Actions)

# Secrets
AWS_ACCESS_KEY_ID= # AWS Access key
AWS_SECRET_ACCESS_KEY= # AWS Secret key
GAC_GITOPS_TOKEN= # Github Access Token
```

### 6. App Deployment
```sh
# app-files/gac-gitops/gac-argocd-app.yaml 파일을 apply합니다.
kubectl apply -f app-files/gac-gitops/gac-argocd-app.yaml
```