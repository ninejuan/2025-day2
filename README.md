## WorldSkills Korea 2025 Cloud Computing Day2
---
```
꼭 모든 Bastion에 AWS Configure 해둬야 함.
```
### 1. Implemented Regions
- [x] 서울
- [ ] 경북
- [ ] 충남
- [ ] 광주
- [x] 대전
- [ ] 제주
- [ ] 대구
- [ ] 충북

### 2. Seoul
1. Deploy App Automatically
- Region : ap-northeast-2
- Stacks : ArgoCD, Github Actions, EKS
2. ECS Logger
- Region : us-east-1
- Stacks : ECS Fargate, CloudWatch
3. Secure access to EFS
- Region : eu-west-1
- Stacks : VPC, EC2, EFS
4. VPC Lattice
- Region : ap-southeast-1
- Stacks : VPC, Lattice

### 3. Daejeon
1. NoSQL Database
- Region : ap-northeast-2
- Stacks : DynamoDB, Lambda
2. Edge DRM
- Region : us-east-1
- Stacks : Cloudfront, Lambda
3. CloudWatch Monitoring
- Region : ap-southeast-1
- Stacks : ECS, CloudWatch
4. WAF
- Region : us-west-1
- Stacks : EC2, ALB, WAF

### 4. Gwangju
1. Governance
- Region : us-east-1
- Stacks : Config, IAM, CloudWatch, Lambda
2. CI/CD
- Region : ap-northeast-2
- Stacks : Github Actions, ECR, ECS, ALB
3. Logging
- Region : eu-west-1
- Stacks : VPC, ECR, ECS, CloudWatch
4. Message Queue
- Region : ap-southeast-1
- Stacks : VPC, EC2, Lambda, SQS, CloudWatch