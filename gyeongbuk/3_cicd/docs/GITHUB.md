# GitHub 설정 가이드 (day2-product)

## 0) 반영 전 체크리스트
- [ ] 하드코딩된 Github ID를 모두 대회장 계정 정보로 변경했는가? (주의!)

## 1) 저장소 생성 및 초기 구조
- Public Repository 생성: `day2-product`
- 기본 브랜치: `dev` (초기 main 생성 후 `dev`, `prod` 브랜치 추가, 기본 브랜치를 dev로 변경)
- 디렉터리 구조 커밋:
  - `.github/workflows/dev.yml`, `.github/workflows/prod.yml`
  - `Dockerfile`, `app.py`, `requirements.txt`
  - `charts/app/` (Helm 차트명: app), `values/dev.values.yaml`, `values/prod.values.yaml`

## 2) 브랜치 전략
- feature/* -> dev 로 PR 생성 시:
  - Self-hosted Runner(dev)에서 dev 파이프라인 실행
  - PR 자동 merge -> ECR push(tag=commit SHA) -> values/dev 업데이트 -> ArgoCD sync(dev)
- dev -> prod 로 PR 생성 시:
  - `approval` 라벨이 있는 경우에만 Self-hosted Runner(prod)에서 prod 파이프라인 실행
  - FF merge -> ECR push(tag=commit SHA) -> values/prod 업데이트 -> ArgoCD sync(prod)

## 3) 라벨
- `approval`: prod 배포 승인용 라벨 (Color #008fff 권장)

## 4) GitHub Secrets (Repo-level)
- `AWS_ROLE_ARN`: Terraform 출력값 `github_actions_role_arn`
- `ARGOCD_SERVER`: dev-cluster ArgoCD Server 주소 (LB 또는 NodePort)
- `ARGOCD_TOKEN`: ArgoCD `github-actions` 계정 API 토큰

## 5) Github Pages (ArgoCD Helm Chart source)
- Argo Application은 Helm Chart의 Source로 user.github.io/day2-product/charts 형태의 URL을 참조해야 함.
- 즉, Github Pages를 사용하여 Chart를 호스팅해야 함.
- Settings -> Pages -> Deploy from a Branch -> main 브랜치 (path : /(root))로 설정하고 호스팅.

## 6) Self-hosted Runner (ARC)
- dev/prod 클러스터에 각각 2개씩 Runner 유지
- 라벨: `dev`, `prod` (워크플로우에서 `runs-on: [self-hosted, dev]` / `runs-on: [self-hosted, prod]` 사용)

## 7) 워크플로우 요약
- dev.yml
  - 트리거: PR to dev (opened/synchronize/reopened)
  - 동작: PR 자동 merge -> buildx (linux/amd64, arm64) -> ECR push(tag=commit SHA) -> values/dev 갱신 -> ArgoCD sync(dev)
- prod.yml
  - 트리거: PR to prod (labeled) w. `approval`
  - 동작: FF merge dev->prod -> buildx -> ECR push -> values/prod 갱신 -> ArgoCD sync(prod)

## 8) 마지막 체크리스트
- [ ] Dev, Prod VPC에 Subnet이 4개인가?
- [ ] 스크립트 1의 출력 결과가 Private인가?
- [ ] (dev cluster) Product pod, Runner가 각각 2개씩 운영중인가?
- [ ] Helm chart로 gh pages를 참조하고 있는가?
- [ ] 계정에 다른 Repo가 없고, 기본 브랜치가 dev인가?

## 9) 스크립트 1
```sh
for c in dev-cluster prod-cluster; do
  subnets=($(aws eks describe-cluster --name $c --query "cluster.resourcesVpcConfig.subnetIds[]" --out text))
  for s in "${subnets[@]}"; do
    [[ $(aws ec2 describe-subnets --subnet-ids $s --q "Subnets[0].MapPublicIpOnLaunch" --out text) == "True" ]] && echo "Public" && break
  done || echo "Private"
done
```