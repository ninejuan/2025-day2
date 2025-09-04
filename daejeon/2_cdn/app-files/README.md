# Edge DRM 샘플 미디어 파일

이 디렉토리는 Edge DRM 테스트를 위한 샘플 미디어 파일들을 포함합니다.

## 파일 구조

```
app-files/
├── README.md          # 이 파일
├── sample.mp4         # 샘플 비디오 파일 1
├── demo.mp4           # 샘플 비디오 파일 2
└── test-script.sh     # DRM 테스트 스크립트
```

## 샘플 파일 생성

실제 MP4 파일이 필요한 경우, 다음 명령어로 샘플 파일을 생성할 수 있습니다:

```bash
# FFmpeg가 설치되어 있는 경우
ffmpeg -f lavfi -i testsrc=duration=10:size=320x240:rate=1 -f lavfi -i sine=frequency=1000:duration=10 -c:v libx264 -c:a aac -shortest sample.mp4
ffmpeg -f lavfi -i testsrc=duration=15:size=640x480:rate=1 -f lavfi -i sine=frequency=2000:duration=15 -c:v libx264 -c:a aac -shortest demo.mp4
```

## DRM 테스트

배포 완료 후 다음 URL로 DRM 기능을 테스트할 수 있습니다:

1. **유효한 DRM 토큰으로 요청** (성공):
   ```
   https://<cloudfront-domain>/media/sample.mp4?drm_token=drm-cloud
   ```

2. **DRM 토큰 없이 요청** (403 Forbidden):
   ```
   https://<cloudfront-domain>/media/sample.mp4
   ```

3. **잘못된 DRM 토큰으로 요청** (403 Forbidden):
   ```
   https://<cloudfront-domain>/media/sample.mp4?drm_token=invalid-token
   ```

## 주의사항

- 실제 운영 환경에서는 더 큰 미디어 파일을 사용하세요
- DRM 토큰은 보안상 민감한 정보이므로 안전하게 관리하세요
- CloudFront 배포가 완전히 전파되는 데 시간이 걸릴 수 있습니다 (15-20분)
