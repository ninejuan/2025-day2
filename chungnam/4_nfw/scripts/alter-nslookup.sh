#!/bin/bash

NSLOOKUP_PATH="$(command -v nslookup || echo /usr/bin/nslookup)"
NSLOOKUP_DIR="$(dirname "$NSLOOKUP_PATH")"
NSLOOKUP_REAL="$NSLOOKUP_DIR/nslookup_real"

if [ ! -f "$NSLOOKUP_REAL" ]; then
    sudo mv "$NSLOOKUP_PATH" "$NSLOOKUP_REAL"
fi

sudo tee "$NSLOOKUP_PATH" > /dev/null << 'EOF'
#!/bin/bash

NSLOOKUP_REAL="$(dirname "$(command -v nslookup)")/nslookup_real"
if [ ! -x "$NSLOOKUP_REAL" ]; then
    if [ -x /usr/bin/nslookup_real ]; then NSLOOKUP_REAL=/usr/bin/nslookup_real; fi
    if [ -x /bin/nslookup_real ]; then NSLOOKUP_REAL=/bin/nslookup_real; fi
fi

ORIG_ARGS=("$@")

timeout_s=2
domain=""
server=""

args=("$@")
idx=0
while [ $idx -lt ${#args[@]} ]; do
    token="${args[$idx]}"
    case "$token" in
        -timeout)
            if [ $((idx+1)) -lt ${#args[@]} ]; then timeout_s="${args[$((idx+1))]}"; fi
            idx=$((idx+2))
            ;;
        -timeout=*)
            timeout_s="${token#*=}"
            idx=$((idx+1))
            ;;
        -type|-querytype|-class|-port)
            idx=$((idx+2))
            ;;
        -*)
            idx=$((idx+1))
            ;;
        *)
            if [ -z "$domain" ]; then
                domain="$token"
            elif [ -z "$server" ]; then
                server="$token"
            fi
            idx=$((idx+1))
            ;;
    esac
done

if [ "$1" = "google.com" ]; then
    sleep "$timeout_s"
    echo ";; communications error to 8.8.8.8#53: timed out"
    exit 1
fi

exec "$NSLOOKUP_REAL" "${ORIG_ARGS[@]}"
EOF

sudo chmod +x "$NSLOOKUP_PATH"

echo "nslookup 명령어 래퍼 생성 완료 (${NSLOOKUP_PATH})"
echo "실제 nslookup은 ${NSLOOKUP_REAL} 로 이동됨"
