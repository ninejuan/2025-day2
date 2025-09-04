#!/bin/bash
yum update -y
yum install -y python3 python3-pip git

pip3 install flask boto3

mkdir -p /opt/service-b
cd /opt/service-b
cat > /opt/service-b/service-b.py << 'EOF'
from flask import Flask, jsonify
import boto3
import datetime
import os

app = Flask(__name__)

TABLE_NAME = "service-b-table"

dynamodb = boto3.resource("dynamodb", region_name="ap-southeast-1")
table = dynamodb.Table(TABLE_NAME)

@app.route("/api")
def api():
    now = datetime.datetime.now().isoformat()

    item = {
        "id": "example",
        "timestamp": now
    }
    table.put_item(Item=item)

    return jsonify({"message": "Hello from Service A"})

@app.route("/api/get")
def get_data():
    try:
        response = table.get_item(
            Key={
                "id": "example"
            }
        )
        item = response.get('Item')
        if item:
            return jsonify({"message": "data retrieved", "item": item})
        else:
            return jsonify({"message": "no data found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

cat > /opt/service-b/start-service.sh << 'EOF'
#!/bin/bash
cd /opt/service-b
python3 service-b.py
EOF

chmod +x /opt/service-b/start-service.sh

cat > /etc/systemd/system/service-b.service << EOF
[Unit]
Description=Service B Flask Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/service-b
ExecStart=/opt/service-b/start-service.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable service-b
systemctl start service-b
echo "Service B 설정 완료" > /tmp/service-b-setup.log
echo "Date: $(date)" >> /tmp/service-b-setup.log
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" >> /tmp/service-b-setup.log