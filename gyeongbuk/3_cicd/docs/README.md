# Day2 CI/CD (gyongbuk/3_cicd)

## 개요
- VPC 2개(dev/prod), EKS 2개, Bastion, ECR 2개(product/dev, product/prod)
- ArgoCD(dev 전용), Argo Rollouts(dev/prod), ARC(Self-hosted Runner), ALB Controller
- GitHub Actions(OIDC)로 멀티아키 이미지 빌드 및 ArgoCD Sync

## 빠른 시작
1) GitHub 레포 준비: `day2-product` (구조/시크릿/브랜치/라벨)
2) Terraform로 인프라 배포 (eu-central-1)
3) 수동 애드온 설치
```bash
cd gyeongbuk/3_cicd/app-files
export AWS_REGION=eu-central-1
export DEV_CLUSTER_NAME=dev-cluster
export PROD_CLUSTER_NAME=prod-cluster
bash install-all.sh
```
4) feature/* → dev → prod 파이프라인 동작 확인

## ArgoCD API Token 생성
1. ArgoCD 로그인
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
argocd login <ARGOCD_ALB_URL> --username admin --password <admin-password> --insecure
```

2. API 키 생성
```bash
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data":{"accounts.admin":"apiKey,login"}}'
kubectl rollout restart deployment argocd-server -n argocd
argocd account generate-token --account admin # 이건 ArgoCD UI -> Settings -> Accounts -> admin -> Generate API Key로 해도 됨.
```

3. 생성된 토큰을 GitHub Secrets에 `ARGOCD_TOKEN`으로 저장

## 문서
- GitHub 설정: `GITHUB.md`
- 배포 가이드: `DEPLOYMENT.md`

## 채점 포인트
- Runner(dev/prod) 각 2개, 라벨 `dev`/`prod`
- Rollout 이름 `product`, 네임스페이스 `app`
- Ingress `dev-ingress`/`prod-ingress`, ALB Name `dev-alb`/`prod-alb`
- OIDC로 ECR Push, ArgoCD Sync로 Blue/Green 무중단 배포
