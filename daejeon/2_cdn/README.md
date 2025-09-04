# Edge DRM with CloudFront

이 프로젝트는 AWS CloudFront, CloudFront Function, Lambda@Edge를 사용하여 Edge DRM(Digital Rights Management) 기능을 구현합니다.

## 아키텍처 개요

```
사용자 요청 → CloudFront Function → Lambda@Edge → S3 Origin
     ↓              ↓                    ↓
  Query String   Header 변환         DRM 검증
  (drm_token)    (X-DRM-Token)      (403/200)
```

## 주요 구성 요소

### 1. CloudFront Function (web-cdn-function)
- **위치**: Viewer Request 단계
- **기능**: Query String의 `drm_token`을 `X-DRM-Token` 헤더로 변환
- **런타임**: cloudfront-js-2.0

### 2. Lambda@Edge (web-drm-function)
- **위치**: Origin Request 단계
- **기능**: DRM 토큰 검증 및 403 Forbidden 응답
- **런타임**: Python 3.13
- **유효 토큰**: `drm-cloud`

### 3. S3 버킷 (web-drm-bucket-XXX)
- **이름**: `web-drm-bucket-<3자리숫자>`
- **미디어 경로**: `media/*.mp4`
- **보안**: CloudFront OAI만 접근 가능

### 4. CloudFront 배포 (web-cdn)
- **캐시 TTL**: 60초
- **캐시 키**: DRM 토큰 포함 (사용자별 분리)
- **에러 처리**: 403/404 커스텀 에러 페이지

## 배포 방법

### 1. 사전 준비
```bash
# SSH 키 확인
ls -la cdn-key*

# 샘플 미디어 파일 준비 (선택사항)
# app-files/ 디렉토리에 *.mp4 파일들을 추가
```

### 2. Terraform 변수 설정
```bash
# terraform.tfvars 파일 생성
cp terraform.tfvars.example terraform.tfvars

# 필요시 변수 수정
vim terraform.tfvars
```

### 3. 배포 실행
```bash
# Terraform 초기화
terraform init

# 배포 계획 확인
terraform plan

# 배포 실행
terraform apply
```

### 4. 배포 확인
```bash
# 출력 정보 확인
terraform output

# 테스트 스크립트 실행
./app-files/test-script.sh <cloudfront-domain>
```

## DRM 테스트

### 유효한 토큰으로 요청 (성공)
```bash
curl -I "https://<cloudfront-domain>/media/sample.mp4?drm_token=drm-cloud"
# 예상 응답: 200 OK
```

### DRM 토큰 없이 요청 (차단)
```bash
curl -I "https://<cloudfront-domain>/media/sample.mp4"
# 예상 응답: 403 Forbidden
```

### 잘못된 토큰으로 요청 (차단)
```bash
curl -I "https://<cloudfront-domain>/media/sample.mp4?drm_token=invalid"
# 예상 응답: 403 Forbidden
```

## 보안 특징

1. **토큰 기반 인증**: DRM 토큰이 없으면 접근 차단
2. **사용자별 캐시**: DRM 토큰이 캐시 키에 포함되어 사용자별 분리
3. **짧은 TTL**: 60초 캐시 TTL로 보안성 강화
4. **Origin 보호**: S3 버킷은 CloudFront OAI만 접근 가능

## 모니터링 및 로깅

- CloudFront 액세스 로그 활성화 가능
- Lambda@Edge CloudWatch 로그 (us-east-1 리전)
- CloudFront 메트릭 및 알람 설정 가능

## 비용 최적화

- **가격 클래스**: PriceClass_100 (미국, 유럽, 아시아)
- **캐시 최적화**: 짧은 TTL로 불필요한 캐시 방지
- **압축**: CloudFront 자동 압축 활성화

## 문제 해결

### 일반적인 문제들

1. **403 Forbidden 에러**
   - DRM 토큰 확인: `drm_token=drm-cloud`
   - Lambda@Edge 배포 상태 확인

2. **404 Not Found 에러**
   - S3 버킷에 미디어 파일 존재 확인
   - 파일 경로: `media/*.mp4`

3. **캐시 문제**
   - CloudFront 배포 전파 대기 (15-20분)
   - 캐시 무효화 실행

### 로그 확인
```bash
# Bastion host에서 CloudFront 상태 확인
aws cloudfront get-distribution --id <distribution-id>

# S3 버킷 내용 확인
aws s3 ls s3://<bucket-name>/media/ --recursive
```

## 정리

```bash
# 리소스 삭제
terraform destroy
```

## 주의사항

- Lambda@Edge는 us-east-1에서만 생성 가능
- CloudFront 배포 전파에 시간이 걸림 (15-20분)
- DRM 토큰은 보안상 민감한 정보이므로 안전하게 관리
- 실제 운영 환경에서는 더 강력한 토큰 검증 로직 구현 권장
