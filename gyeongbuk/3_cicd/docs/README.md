# Day2 CI/CD (gyongbuk/3_cicd)

## 개요
- VPC 2개(dev/prod), EKS 2개, Bastion, ECR 2개(product/dev, product/prod)
- ArgoCD(dev 전용), Argo Rollouts(dev/prod), ARC(Self-hosted Runner), ALB Controller
- GitHub Actions(OIDC)로 멀티아키 이미지 빌드 및 ArgoCD Sync

## 빠른 시작
1) Terraform로 인프라 배포 (eu-central-1)
2) 수동 애드온 설치
```bash
cd gyeongbuk/3_cicd/app-files
export AWS_REGION=eu-central-1
export DEV_CLUSTER_NAME=dev-cluster
export PROD_CLUSTER_NAME=prod-cluster
bash install-all.sh
```
3) GitHub 레포 준비: `day2-product` (구조/시크릿/브랜치/라벨)
4) feature/* → dev → prod 파이프라인 동작 확인

## 문서
- GitHub 설정: `GITHUB.md`
- 배포 가이드: `DEPLOYMENT.md`

## 채점 포인트
- Runner(dev/prod) 각 2개, 라벨 `dev`/`prod`
- Rollout 이름 `product`, 네임스페이스 `app`
- Ingress `dev-ingress`/`prod-ingress`, ALB Name `dev-alb`/`prod-alb`
- OIDC로 ECR Push, ArgoCD Sync로 Blue/Green 무중단 배포
