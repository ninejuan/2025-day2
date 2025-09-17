# GitHub 설정 가이드 (day2-product)

## 1) 저장소 생성 및 초기 구조
- Public Repository 생성: `day2-product`
- 기본 브랜치: `dev` (초기 main 생성 후 `dev`, `prod` 브랜치 추가, 기본 브랜치를 dev로 변경)
- 디렉터리 구조 커밋:
  - `.github/workflows/dev.yml`, `.github/workflows/prod.yml`
  - `Dockerfile`, `app.py`, `requirements.txt`
  - `charts/app/` (Helm 차트명: app), `values/dev.values.yaml`, `values/prod.values.yaml`

## 2) 브랜치 전략
- feature/* → dev 로 PR 생성 시:
  - Self-hosted Runner(dev)에서 dev 파이프라인 실행
  - PR 자동 merge → ECR push(tag=commit SHA) → values/dev 업데이트 → ArgoCD sync(dev)
- dev → prod 로 PR 생성 시:
  - `approval` 라벨이 있는 경우에만 Self-hosted Runner(prod)에서 prod 파이프라인 실행
  - FF merge → ECR push(tag=commit SHA) → values/prod 업데이트 → ArgoCD sync(prod)

## 3) 라벨
- `approval`: prod 배포 승인용 라벨

## 4) GitHub Secrets (Repo-level)
- `AWS_ROLE_ARN`: Terraform 출력값 `github_actions_role_arn`
- `ARGOCD_SERVER`: dev-cluster ArgoCD Server 주소 (LB 또는 NodePort)
- `ARGOCD_TOKEN`: ArgoCD `github-actions` 계정 API 토큰

## 5) Self-hosted Runner (ARC)
- dev/prod 클러스터에 각각 2개씩 Runner 유지
- 라벨: `dev`, `prod` (워크플로우에서 `runs-on: [self-hosted, dev]` / `runs-on: [self-hosted, prod]` 사용)

## 6) 워크플로우 요약
- dev.yml
  - 트리거: PR to dev (opened/synchronize/reopened)
  - 동작: PR 자동 merge → buildx (linux/amd64, arm64) → ECR push(tag=commit SHA) → values/dev 갱신 → ArgoCD sync(dev)
- prod.yml
  - 트리거: PR to prod (opened/synchronize/reopened/labeled) with `approval`
  - 동작: FF merge dev→prod → buildx → ECR push → values/prod 갱신 → ArgoCD sync(prod)

## 7) 점검 명령어
- 러너 확인 (4-8 채점)
```bash
GITHUB_USER=<your_user>
gh api repos/"$GITHUB_USER"/day2-product/actions/runners --paginate --jq '.runners[] | select(any(.labels[].name; . == "dev" or . == "prod")) | "\(.name)\t\([.labels[].name] | join(","))"'
```
- 클러스터 내 확인 (2-2 채점)
```bash
kubectl get po -n app --output name | grep product
kubectl get runner -n app --output name
```
