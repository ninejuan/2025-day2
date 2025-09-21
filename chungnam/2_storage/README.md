# Tips

---

## To-Do
- [ ] terraform apply
- [ ] (채점 전) masked/, incoming/ 디렉토리 비우기

### 현재 상황
- 채점기준표 2-6 오답; Macie Job 복제 후 결과에 위험 항목이 6개 생기는지 보는 것.
이 문제는 그냥 해결책대로 하면 됨.

### 해결책
1. /incoming prefix를 target으로 하는 wsc2025-fixed-job을 생성해서 위험 파일로 분류되게 함. 