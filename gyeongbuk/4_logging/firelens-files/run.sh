#!/bin/sh

echo "Starting Fluent Bit with ECS metadata extraction..."

echo "ECS_CONTAINER_METADATA_URI_V4: $ECS_CONTAINER_METADATA_URI_V4"

TASK_JSON=$(curl -s "$ECS_CONTAINER_METADATA_URI_V4/task" 2>/dev/null || true)
TASK_ARN=$(printf '%s' "$TASK_JSON" | tr -d '\n' | sed -n 's/.*"Task[Aa][Rr][Nn]"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
TASK_ID=$(printf '%s' "$TASK_ARN" | awk -F'/' '{print $NF}')
[ -z "$TASK_ID" ] && TASK_ID="unknown"
export ECS_TASK_ID="$TASK_ID"

echo "TASK_JSON length: $(echo "$TASK_JSON" | wc -c)"
echo "TASK_ARN: $TASK_ARN" 
echo "Final ECS_TASK_ID: $ECS_TASK_ID"
echo "Expected log stream name: logs/$ECS_TASK_ID"

cat > /tmp/fluent-bit.conf << EOF
[SERVICE]
    Parsers_File /fluent-bit/etc/parsers.conf
    Log_Level    debug
    HTTP_Server  On
    HTTP_Listen  0.0.0.0
    HTTP_Port    2020

[INPUT]
    Name forward
    Listen 0.0.0.0
    Port 24224

[INPUT]
    Name forward
    Unix_Path /var/run/fluent.sock

[FILTER]
    Name parser
    Match *
    Key_Name log
    Parser flask_access_log
    Reserve_Data On

[FILTER]
    Name parser
    Match *
    Key_Name message
    Parser flask_access_log
    Reserve_Data On

[FILTER]
    Name parser
    Match *
    Key_Name log
    Parser generic_log
    Reserve_Data On

[FILTER]
    Name parser
    Match *
    Key_Name message
    Parser generic_log
    Reserve_Data On

[FILTER]
    Name modify
    Match *
    Set ecs_task_id $ECS_TASK_ID

[OUTPUT]
    Name cloudwatch_logs
    Match *
    region eu-west-1
    log_group_name /skills/app
    log_stream_name logs/$ECS_TASK_ID
    log_format json
    auto_create_group true
    retry_limit 3
EOF

echo "Generated Fluent Bit config:"
cat /tmp/fluent-bit.conf

echo "Starting Fluent Bit..."
exec /fluent-bit/bin/fluent-bit -c /tmp/fluent-bit.conf