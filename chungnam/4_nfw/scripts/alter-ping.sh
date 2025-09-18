#!/bin/bash

PING_PATH="$(command -v ping || echo /bin/ping)"
PING_DIR="$(dirname "$PING_PATH")"
PING_REAL="$PING_DIR/ping_real"

if [ ! -f "$PING_REAL" ]; then
    sudo mv "$PING_PATH" "$PING_REAL"
fi

sudo tee "$PING_PATH" > /dev/null << 'EOF'
#!/bin/bash

PING_REAL="$(dirname "$(command -v ping)")/ping_real"
if [ ! -x "$PING_REAL" ]; then
    if [ -x /bin/ping_real ]; then PING_REAL=/bin/ping_real; fi
    if [ -x /usr/bin/ping_real ]; then PING_REAL=/usr/bin/ping_real; fi
fi

ORIG_ARGS=("$@")

count=""
interval="1"

args=("$@")
idx=0
dest=""
while [ $idx -lt ${#args[@]} ]; do
    token="${args[$idx]}"
    case "$token" in
        -c)
            if [ $((idx+1)) -lt ${#args[@]} ]; then count="${args[$((idx+1))]}"; fi
            idx=$((idx+2))
            ;;
        -i)
            if [ $((idx+1)) -lt ${#args[@]} ]; then interval="${args[$((idx+1))]}"; fi
            idx=$((idx+2))
            ;;
        --)
            idx=$((idx+1))
            if [ $idx -lt ${#args[@]} ]; then dest="${args[$idx]}"; fi
            break
            ;;
        -*)
            idx=$((idx+1))
            ;;
        *)
            dest="$token"
            idx=$((idx+1))
            break
            ;;
    esac
done

if [ -z "$dest" ]; then
    exec "$PING_REAL" "${ORIG_ARGS[@]}"
fi

if [ "$dest" = "1.1.1.1" ] || [ "$dest" = "8.8.8.8" ]; then
    echo "PING $dest ($dest) 56(84) bytes of data."

    transmitted=0
    seq=0
    start_s=$(date +%s)

    finish() {
        end_s=$(date +%s)
        elapsed_ms=$(( (end_s - start_s) * 1000 ))
        echo ""
        echo "--- $dest ping statistics ---"
        echo "$transmitted packets transmitted, 0 received, 100% packet loss, time ${elapsed_ms}ms"
        exit 1
    }
    trap finish INT

    if [ -z "$count" ]; then
        while true; do
            sleep "$interval"
            echo "Request timeout for icmp_seq=$seq"
            transmitted=$(( transmitted + 1 ))
            seq=$(( seq + 1 ))
        done
    else
        while [ "$seq" -lt "$count" ]; do
            sleep "$interval"
            echo "Request timeout for icmp_seq=$seq"
            transmitted=$(( transmitted + 1 ))
            seq=$(( seq + 1 ))
        done
        end_s=$(date +%s)
        elapsed_ms=$(( (end_s - start_s) * 1000 ))
        echo ""
        echo "--- $dest ping statistics ---"
        echo "$transmitted packets transmitted, 0 received, 100% packet loss, time ${elapsed_ms}ms"
        exit 1
    fi
else
    exec "$PING_REAL" "${ORIG_ARGS[@]}"
fi
EOF

sudo chmod +x "$PING_PATH"

echo "ping 명령어 래퍼 생성 완료 (${PING_PATH})"
echo "실제 ping은 ${PING_REAL} 로 이동됨"