#!/bin/bash
yum update -y
yum install -y python3 python3-pip git

pip3 install flask requests

mkdir -p /opt/service-a
cd /opt/service-a
cat > /opt/service-a/service-a.py << 'EOF'
from flask import Flask, jsonify
import requests
import os

app = Flask(__name__)

LATTICE_SERVICE_B_URL = os.environ.get('LATTICE_SERVICE_B_URL', 'http://localhost/api')

@app.route("/hello")
def hello():
    return jsonify({"message": "Hello from Service A"})

@app.route("/call-service-b")
def call_service_b():
    try:
        res = requests.get(LATTICE_SERVICE_B_URL, timeout=2)
        return res.text, res.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

cat > /opt/service-a/start-service.sh << 'EOF'
#!/bin/bash
cd /opt/service-a
export LATTICE_SERVICE_B_URL="http://service-b-lattice.lattice-net/api"
python3 service-a.py
EOF

chmod +x /opt/service-a/start-service.sh

cat > /etc/systemd/system/service-a.service << EOF
[Unit]
Description=Service A Flask Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/service-a
ExecStart=/opt/service-a/start-service.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable service-a
systemctl start service-a
echo "Service A 설정 완료" > /tmp/service-a-setup.log
echo "Date: $(date)" >> /tmp/service-a-setup.log
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" >> /tmp/service-a-setup.log
