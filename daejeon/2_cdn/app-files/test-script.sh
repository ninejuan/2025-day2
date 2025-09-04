#!/bin/bash

# Edge DRM 테스트 스크립트
# 사용법: ./test-script.sh <cloudfront-domain>

if [ $# -eq 0 ]; then
    echo "사용법: $0 <cloudfront-domain>"
    echo "예시: $0 d1234567890.cloudfront.net"
    exit 1
fi

CLOUDFRONT_DOMAIN=$1
BASE_URL="https://$CLOUDFRONT_DOMAIN"
DRM_TOKEN="drm-cloud"

echo "=== Edge DRM 테스트 시작 ==="
echo "CloudFront 도메인: $CLOUDFRONT_DOMAIN"
echo ""

# 테스트 1: 유효한 DRM 토큰으로 요청
echo "테스트 1: 유효한 DRM 토큰으로 요청"
echo "URL: $BASE_URL/media/sample.mp4?drm_token=$DRM_TOKEN"
echo "예상 결과: 200 OK"
curl -I "$BASE_URL/media/sample.mp4?drm_token=$DRM_TOKEN"
echo ""

# 테스트 2: DRM 토큰 없이 요청
echo "테스트 2: DRM 토큰 없이 요청"
echo "URL: $BASE_URL/media/sample.mp4"
echo "예상 결과: 403 Forbidden"
curl -I "$BASE_URL/media/sample.mp4"
echo ""

# 테스트 3: 잘못된 DRM 토큰으로 요청
echo "테스트 3: 잘못된 DRM 토큰으로 요청"
echo "URL: $BASE_URL/media/sample.mp4?drm_token=invalid-token"
echo "예상 결과: 403 Forbidden"
curl -I "$BASE_URL/media/sample.mp4?drm_token=invalid-token"
echo ""

# 테스트 4: 존재하지 않는 파일 요청
echo "테스트 4: 존재하지 않는 파일 요청"
echo "URL: $BASE_URL/media/nonexistent.mp4?drm_token=$DRM_TOKEN"
echo "예상 결과: 404 Not Found"
curl -I "$BASE_URL/media/nonexistent.mp4?drm_token=$DRM_TOKEN"
echo ""

echo "=== 테스트 완료 ==="
echo ""
echo "참고사항:"
echo "- CloudFront 배포가 완전히 전파되는 데 15-20분이 걸릴 수 있습니다"
echo "- 캐시 TTL이 60초로 설정되어 있어 사용자별로 캐시가 분리됩니다"
echo "- DRM 토큰이 캐시 키에 포함되어 보안이 강화됩니다"
