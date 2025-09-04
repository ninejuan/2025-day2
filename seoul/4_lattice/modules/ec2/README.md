# EC2 모듈

EC2 인스턴스와 Elastic IP를 생성하는 재사용 가능한 Terraform 모듈입니다.

## 구조

```
modules/ec2/
├── main.tf              # EC2 인스턴스 및 EIP 리소스
├── variables.tf          # 모듈 변수 정의
├── outputs.tf            # 모듈 출력 값
├── README.md             # 이 파일
├── userdata/             # 사용자 데이터 스크립트들
│   ├── bastion-user-data.sh
│   ├── service-a-user-data.sh
│   └── service-b-user-data.sh
└── keys/                 # SSH 키 파일들
    ├── bastion-key       # SSH 개인키
    └── bastion-key.pub   # SSH 공개키
```

## 사용법

```hcl
module "bastion" {
  source = "./modules/ec2"
  
  ami_id = "ami-12345"
  instance_type = "t3.micro"
  key_name = "bastion-key"
  subnet_id = module.vpc.public_subnet_id
  security_group_ids = [module.bastion_sg.security_group_id]
  instance_name = "bastion-host"
  create_eip = true
  
  tags = {
    Name = "bastion"
    Environment = "production"
  }
}
```

## 변수

- `ami_id`: EC2 AMI ID (필수)
- `instance_type`: 인스턴스 타입 (기본값: t3.micro)
- `key_name`: SSH 키 페어 이름 (필수)
- `subnet_id`: 서브넷 ID (필수)
- `security_group_ids`: 보안 그룹 ID 리스트 (필수)
- `iam_instance_profile_name`: IAM 인스턴스 프로필 이름 (선택)
- `user_data_template`: 사용자 데이터 템플릿 파일 경로 (선택)
- `user_data_vars`: 사용자 데이터 템플릿 변수 (선택)
- `instance_name`: 인스턴스 이름 (필수)
- `create_eip`: Elastic IP 생성 여부 (기본값: false)
- `tags`: 리소스 태그 (선택)

## 출력

- `instance_id`: EC2 인스턴스 ID
- `private_ip`: Private IP 주소
- `public_ip`: Public IP 주소
- `eip_public_ip`: Elastic IP Public IP (EIP 생성 시에만)
