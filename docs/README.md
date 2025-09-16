# CI/CD 배포 문서 모음

- 상세 가이드: `../gyongbuk/3_cicd/DEPLOYMENT.md`
- 수동 설치 스크립트: `../gyongbuk/3_cicd/app-files/install-all.sh`

요약:
- GitHub Public Repo `day2-product` 구성 및 브랜치 전략
- GitHub OIDC + ECR 푸시, ArgoCD Sync 기반 Blue/Green 배포
- dev/prod Self-hosted Runner 2대씩 유지 (ARC RunnerDeployment)
- Ingress(ALB) 네이밍 규칙 및 네임스페이스 정책 준수
