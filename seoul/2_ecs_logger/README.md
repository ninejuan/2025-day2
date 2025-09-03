# ECS Logger
---

## 모듈 구조
```
modules/
├── vpc/           # VPC, 서브넷, 라우팅, 보안그룹, ALB
├── iam/           # IAM 역할 및 정책
├── ecs/           # ECS 클러스터, 서비스, 태스크
├── cloudwatch/    # CloudWatch 경보
└── bastion/       # Bastion Host
```

## 사용법

1. **Terraform 초기화**:
```bash
terraform init
```

2. **변수 설정**:
```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일에서 필요한 값들을 설정
```

3. **계획 확인**:
```bash
terraform plan
```

4. **인프라 배포**:
```bash
terraform apply
```

5. **인프라 삭제**:
```bash
terraform destroy
```
