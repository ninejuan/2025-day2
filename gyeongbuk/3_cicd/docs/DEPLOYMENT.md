# WorldSkills Korea 2025 - Day2 CI/CD 배포 가이드

## 개요
- 본 문서는 dev/prod VPC + EKS, ArgoCD(dev 전용), ARC(Self-hosted Runner), ALB, ECR, GitHub Actions(OIDC) 기반의 파이프라인 운영 지침입니다.
- Terraform으로 인프라(ECR/VPC/EKS/Bastion/IRSA 등)만 구성하고, Helm 기반 애드온(ArgoCD, Argo Rollouts, AWS Load Balancer Controller, ARC)은 `app-files`의 스크립트로 수동 설치합니다.

## 사전 준비
- AWS Region: eu-central-1
- 필수 도구: awscli, kubectl, argocd, gh
- Terraform 출력 확인:
  - `terraform output github_actions_role_arn`
  - `terraform output dev_cluster_endpoint`, `terraform output prod_cluster_endpoint`
  - `terraform output dev_alb_dns_name`, `terraform output prod_alb_dns_name`

## 1) GitHub Repository 세팅 (day2-product)
1. Public Repo 생성: `day2-product`
2. 기본 브랜치: `main` → `dev`, `prod` 브랜치 생성, 기본 브랜치를 `dev`로 설정
3. 라벨 생성: `approval`
4. 디렉터리 구조 커밋 (main 기준)
   - `.github/workflows/dev.yml`, `.github/workflows/prod.yml`
   - `Dockerfile`, `app.py`, `requirements.txt`
   - `charts/app/` (Helm chart 이름: `app`)
   - `values/dev.values.yaml`, `values/prod.values.yaml`
5. 브랜치 전략
   - feature/* → dev 로 PR 생성 시 dev 파이프라인 수행 및 자동 merge + 배포
   - dev → prod 로 PR 생성 후 `approval` 라벨 부여 시 prod 파이프라인 수행 및 FF merge + 배포

### GitHub Secrets (Repo-level)
- `AWS_ROLE_ARN`: Terraform 출력값 `github_actions_role_arn`
- `AWS_REGION`: `eu-central-1`
- `ARGOCD_SERVER`: dev-cluster ArgoCD Server LoadBalancer DNS 또는 NodePort 주소
- `ARGOCD_TOKEN`: ArgoCD `github-actions` 계정 토큰
- `ARGOCD_APP_NAME_DEV`: `dev`
- `ARGOCD_APP_NAME_PROD`: `prod`

## 2) 수동 애드온 설치 (Helm 삭제에 따른 수동화)
Terraform으로 helm 모듈을 제거했으므로, 다음 순서로 수동 설치합니다.

- 위치: `gyongbuk/3_cicd/app-files`
- 실행: `./install-all.sh`

설치 내용:
- dev 클러스터
  - namespace: `argocd`, `argo-rollouts`, `app`, `actions-runner-system`
  - ArgoCD 설치 및 초기화, Argo Rollouts 설치, AWS Load Balancer Controller(IRSA 연동), Actions Runner Controller 설치
  - ArgoCD Application(dev) 적용: `app-files/argocd/dev-application.yaml`
  - prod 클러스터 등록: 설치 스크립트가 prod EKS를 `argocd`에 자동 등록
- prod 클러스터
  - namespace: `argo-rollouts`, `app`, `actions-runner-system`
  - Argo Rollouts 설치, AWS Load Balancer Controller(IRSA 연동), Actions Runner Controller 설치
  - ArgoCD(dev에서 prod 클러스터 등록 후) Application(prod) 적용: `app-files/argocd/prod-application.yaml`
- ARC Runner 생성: `app` 네임스페이스에 dev/prod RunnerDeployment 2개씩

## 3) ArgoCD 계정/토큰 준비
- dev 클러스터의 ArgoCD admin 초기 패스워드 확인 후 로그인
- `github-actions` 계정 생성 및 정책 부여, 토큰 발급
- 해당 토큰을 GitHub Secret `ARGOCD_TOKEN`에 저장

### prod 클러스터 등록 확인
```bash
argocd cluster list
# NAME                                      SERVER                                              NAME
# prod-cluster                              https://<prod-eks-endpoint>                         prod-cluster
```

## 4) 파이프라인 동작
- feature/* → dev PR:
  - dev Runner(self-hosted, dev)에서 실행
  - OIDC로 ECR 로그인 → 멀티아키(조건부) 이미지 빌드/푸시(tag=commit SHA)
  - `values/dev.values.yaml` 이미지 태그 갱신 → dev 브랜치 푸시
  - `argocd app sync dev` 수행 → Blue/Green 배포 완료 시 기존 Pod 종료
- dev → prod PR + `approval` 라벨:
  - prod Runner(self-hosted, prod)에서 실행
  - dev → prod FF merge
  - OIDC로 ECR 로그인 → 이미지 빌드/푸시(tag=commit SHA)
  - `values/prod.values.yaml` 이미지 태그 갱신 → prod 브랜치 푸시
  - `argocd app sync prod` 수행

### 배포 검증
```bash
# dev
kubectl --context arn:aws:eks:eu-central-1:<ACCOUNT_ID>:cluster/dev-cluster -n app get po -l app.kubernetes.io/name=app
kubectl --context arn:aws:eks:eu-central-1:<ACCOUNT_ID>:cluster/dev-cluster -n app get rollout product

# prod
kubectl --context arn:aws:eks:eu-central-1:<ACCOUNT_ID>:cluster/prod-cluster -n app get po -l app.kubernetes.io/name=app
kubectl --context arn:aws:eks:eu-central-1:<ACCOUNT_ID>:cluster/prod-cluster -n app get rollout product
```

## 5) 채점기준 대응 체크
- Runners: 2(dev), 2(prod) 유지, 라벨 `dev`/`prod` 부여
- Namespaces: `app`, `argocd`(dev), `argo-rollouts`
- Rollout 리소스 이름: `product`
- Application 이름: `dev`, `prod`
- Ingress 이름: `dev-ingress`, `prod-ingress` (ALB 이름 태그: `dev-alb`, `prod-alb`)

## 트러블슈팅
- Runner 미표시: ARC 설치 네임스페이스/Secret 일치 여부 확인, GitHub 토큰 권한 확인
- ArgoCD sync 실패: repoURL, targetRevision, prod destination server URL 확인
- ECR 푸시 실패: GitHub OIDC Role, `AWS_ROLE_ARN`/`AWS_REGION` Secret 확인
