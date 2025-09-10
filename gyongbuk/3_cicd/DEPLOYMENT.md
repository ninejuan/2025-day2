# EKS CI/CD Pipeline Deployment Guide

이 가이드는 Actions Runner Controller와 ArgoCD를 활용한 완전한 CI/CD 파이프라인을 구축하는 방법을 설명합니다.

## 전제 조건

1. AWS CLI 설정 (AdministratorAccess 권한)
2. Terraform 설치
3. kubectl 설치
4. GitHub 계정 및 조직
5. SSH 키페어 생성 (`cicd-key`)

## 1. 인프라 배포

```bash
# Terraform 변수 설정
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars에서 github_org 설정

# 인프라 배포
./setup.sh your-github-org
```

## 2. GitHub Repository 설정

1. `day2-product` 리포지토리 생성
2. `day2-product/` 폴더 내용을 리포지토리에 푸시
3. dev, prod 브랜치 생성 (main에서 분기)
4. dev를 기본 브랜치로 설정
5. `approval` 라벨 생성

## 3. GitHub Secrets 설정

다음 시크릿들을 GitHub 리포지토리에 추가:

- `AWS_ROLE_ARN`: Terraform 출력의 `github_actions_role_arn`
- `ARGOCD_SERVER`: ArgoCD 서버 URL (LoadBalancer URL)
- `ARGOCD_AUTH_TOKEN`: ArgoCD 인증 토큰

## 4. GitHub Personal Access Token 생성

1. GitHub에서 Fine-grained PAT 생성
2. Repository permissions: Actions (write), Administration (write), Metadata (read)
3. Base64로 인코딩: `echo -n "your-token" | base64`

## 5. ArgoCD 및 관련 컴포넌트 배포

### 5.1 Dev 클러스터에 배포

```bash
# ArgoCD 배포
kubectl apply -f app-files/argocd/ --context=dev-cluster

# Argo Rollouts 배포
kubectl apply -f app-files/argo-rollouts/ --context=dev-cluster

# cert-manager 배포
kubectl apply -f app-files/actions-runner-controller/cert-manager.yaml --context=dev-cluster

# GitHub 토큰 시크릿 업데이트
kubectl create secret generic controller-manager \
  --from-literal=github_token=YOUR_GITHUB_TOKEN \
  -n actions-runner-system \
  --context=dev-cluster

# Actions Runner Controller 배포
kubectl apply -f app-files/actions-runner-controller/actions-runner-controller.yaml --context=dev-cluster
kubectl apply -f app-files/actions-runner-controller/dev-runner-deployment.yaml --context=dev-cluster
```

### 5.2 Prod 클러스터에 배포

```bash
# Argo Rollouts만 배포
kubectl apply -f app-files/argo-rollouts/argo-rollouts-install.yaml --context=prod-cluster

# cert-manager 배포
kubectl apply -f app-files/actions-runner-controller/cert-manager.yaml --context=prod-cluster

# GitHub 토큰 시크릿 업데이트
kubectl create secret generic controller-manager \
  --from-literal=github_token=YOUR_GITHUB_TOKEN \
  -n actions-runner-system \
  --context=prod-cluster

# Actions Runner Controller 배포
kubectl apply -f app-files/actions-runner-controller/actions-runner-controller.yaml --context=prod-cluster
kubectl apply -f app-files/actions-runner-controller/prod-runner-deployment.yaml --context=prod-cluster
```

## 6. ArgoCD 설정

### 6.1 ArgoCD 서버 URL 획득

```bash
kubectl get svc argocd-server -n argocd --context=dev-cluster
```

### 6.2 ArgoCD 관리자 패스워드 획득

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" --context=dev-cluster | base64 -d
```

### 6.3 ArgoCD에 Prod 클러스터 등록

1. ArgoCD UI에 로그인
2. Settings > Clusters > New Cluster
3. Prod 클러스터 정보 입력

### 6.4 Application 파일 업데이트 및 배포

```bash
# Repository URL 업데이트
sed -i 's/YOUR_GITHUB_ORG/your-github-org/g' app-files/argocd/*-application.yaml

# Prod 클러스터 서버 URL 업데이트
PROD_SERVER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[?(@.name=="prod-cluster")].cluster.server}')
sed -i "s|PROD_CLUSTER_SERVER_URL|$PROD_SERVER_URL|g" app-files/argocd/prod-application.yaml

# Applications 배포
kubectl apply -f app-files/argocd/dev-application.yaml --context=dev-cluster
kubectl apply -f app-files/argocd/prod-application.yaml --context=dev-cluster
```

## 7. 초기 이미지 빌드 및 푸시

```bash
# Dev 이미지 빌드 및 푸시
docker build -t $(terraform output -raw dev_ecr_repository_url):latest .
docker push $(terraform output -raw dev_ecr_repository_url):latest

# Prod 이미지 빌드 및 푸시
docker build -t $(terraform output -raw prod_ecr_repository_url):latest .
docker push $(terraform output -raw prod_ecr_repository_url):latest

# Values 파일 업데이트
ECR_DEV_URL=$(terraform output -raw dev_ecr_repository_url)
ECR_PROD_URL=$(terraform output -raw prod_ecr_repository_url)

sed -i "s|repository: \"\"|repository: \"$ECR_DEV_URL\"|g" day2-product/values/dev.values.yaml
sed -i "s|tag: \"\"|tag: \"latest\"|g" day2-product/values/dev.values.yaml

sed -i "s|repository: \"\"|repository: \"$ECR_PROD_URL\"|g" day2-product/values/prod.values.yaml
sed -i "s|tag: \"\"|tag: \"latest\"|g" day2-product/values/prod.values.yaml
```

## 8. 테스트

### 8.1 CI/CD 파이프라인 테스트

1. Feature 브랜치 생성 및 코드 변경
2. Dev 브랜치로 PR 생성 및 병합
3. Dev 파이프라인 자동 실행 확인
4. Dev에서 Prod로 PR 생성
5. `approval` 라벨 추가 후 병합
6. Prod 파이프라인 자동 실행 확인

### 8.2 애플리케이션 접근

```bash
# ALB DNS 이름 확인
terraform output dev_alb_dns_name
terraform output prod_alb_dns_name

# API 테스트
curl http://<alb-dns-name>/api
curl http://<alb-dns-name>/health
```

## 9. 모니터링

- ArgoCD UI: Applications 상태 확인
- Argo Rollouts Dashboard: 배포 진행 상황 확인
- GitHub Actions: Workflow 실행 상태 확인
- EKS Console: 클러스터 상태 확인

## 10. 문제 해결

### Runner 상태 확인
```bash
kubectl get runnerdeployment -n actions-runner-system --context=dev-cluster
kubectl get runnerdeployment -n actions-runner-system --context=prod-cluster
```

### ArgoCD 애플리케이션 상태 확인
```bash
kubectl get applications -n argocd --context=dev-cluster
```

### Rollout 상태 확인
```bash
kubectl get rollouts -n app --context=dev-cluster
kubectl get rollouts -n app --context=prod-cluster
```
