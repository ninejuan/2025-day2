#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <ALB_DNS_NAME>"
    echo "Example: $0 wsc2025-waf-alb-123456789.us-east-1.elb.amazonaws.com"
    exit 1
fi

ALB_DNS=$1
BASE_URL="http://${ALB_DNS}"

echo "Testing WAF protection against SQL Injection attacks..."
echo "Base URL: $BASE_URL"
echo "========================================="

echo "1. Testing normal login (should work):"
curl -s "${BASE_URL}/login?name=admin&secret=supersecret" | head -1
echo ""

echo "2. Testing SQL injection in login name (should be blocked):"
curl -s "${BASE_URL}/login?name=admin'%20OR%20'1'='1&secret=test" | head -1
echo ""

echo "3. Testing SQL injection in login secret (should be blocked):"
curl -s "${BASE_URL}/login?name=admin&secret=test'%20OR%20'1'='1" | head -1
echo ""

echo "4. Testing normal lookup (should work):"
curl -s "${BASE_URL}/lookup?id=1" | head -1
echo ""

echo "5. Testing SQL injection in lookup (should be blocked):"
curl -s "${BASE_URL}/lookup?id=1%20UNION%20SELECT%20*%20FROM%20secret_users" | head -1
echo ""

echo "6. Testing another SQL injection variant (should be blocked):"
curl -s "${BASE_URL}/lookup?id=1;%20DROP%20TABLE%20secret_users;--" | head -1
echo ""

echo "7. Testing UNION attack (should be blocked):"
curl -s "${BASE_URL}/lookup?id=999%20UNION%20ALL%20SELECT%20id,name,secret%20FROM%20secret_users--" | head -1
echo ""

echo "8. Testing comment-based injection (should be blocked):"
curl -s "${BASE_URL}/login?name=admin'--&secret=anything" | head -1
echo ""

echo "========================================="
echo "If WAF is working correctly:"
echo "- Normal requests should return application responses"
echo "- SQL injection attempts should return 403 Forbidden errors"
