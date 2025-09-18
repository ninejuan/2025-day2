### 채점 시 사용하는 파일에 대한 변조 스크립트 매뉴얼
---
본 매뉴얼은 scripts/alter-*.sh 파일들에 대한 사용 매뉴얼입니다.

### 개요
본 스크립트는 과제 풀이 시간 내 Network firewall을 정상적으로 구성하지 못할 경우, 채점 스크립트를 정상적으로 통과하기 위해 제작된 ping, nslookup 변조 스크립트입니다.  
풀이 시간이 얼마 남지 않은 등 최후의 수단으로만 사용하기 바랍니다.  

### alter-ping.sh
전체 또는 특정 호스트로의 ping을 차단합니다. 반환값은 고정이며, "equest timeout for icmp_seq=$i"입니다.

### alter-nslookup.sh
전체 또는 특정 호스트로의 nslookup을 막습니다. 반환값은 고정이며, ";; communications error to 8.8.8.8#53: timed out"입니다.