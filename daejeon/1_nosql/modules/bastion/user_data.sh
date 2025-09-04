#!/bin/bash

# Update system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip git

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install boto3 for testing
pip3 install boto3

# Create test directory
mkdir -p /opt/dynamodb-test
cd /opt/dynamodb-test

# Create a simple test script
cat > test_dynamodb.py << 'EOF'
import boto3
import json
from decimal import Decimal
from datetime import datetime

def test_dynamodb():
    """Test DynamoDB operations"""
    try:
        # Initialize DynamoDB client
        dynamodb = boto3.resource('dynamodb', region_name='${table_region}')
        table_name = '${table_name}'
        table = dynamodb.Table(table_name)
        
        print(f"Testing DynamoDB table: {table_name}")
        
        # Test creating an account
        account_id = "test-account"
        current_time = datetime.utcnow().isoformat() + 'Z'
        
        item = {
            'account_id': account_id,
            'balance': Decimal('1000'),
            'currency': 'USD',
            'created_at': current_time,
            'last_updated': current_time
        }
        
        # Put item
        table.put_item(Item=item)
        print(f"✓ Created test account: {account_id}")
        
        # Get item
        response = table.get_item(Key={'account_id': account_id})
        if 'Item' in response:
            print(f"✓ Retrieved account: {response['Item']}")
        else:
            print("✗ Failed to retrieve account")
            
        # Clean up - delete test account
        table.delete_item(Key={'account_id': account_id})
        print(f"✓ Deleted test account: {account_id}")
        
        print("DynamoDB test completed successfully!")
        
    except Exception as e:
        print(f"✗ DynamoDB test failed: {str(e)}")

if __name__ == "__main__":
    test_dynamodb()
EOF

# Create a simple API test script
cat > test_api.py << 'EOF'
import requests
import json
import time

def test_api():
    """Test the account API"""
    try:
        # Wait for the service to be ready
        print("Waiting for API service to be ready...")
        time.sleep(30)
        
        # Test health check
        try:
            response = requests.get('http://localhost:8080/healthcheck', timeout=10)
            if response.status_code == 200:
                print("✓ Health check passed")
            else:
                print(f"✗ Health check failed: {response.status_code}")
        except Exception as e:
            print(f"✗ Health check error: {str(e)}")
        
        # Test create account
        try:
            create_data = {
                "account_id": "test-api-account",
                "balance": 1000,
                "currency": "USD"
            }
            response = requests.post('http://localhost:8080/create_account', 
                                   json=create_data, timeout=10)
            if response.status_code == 201:
                print("✓ Create account API passed")
            else:
                print(f"✗ Create account API failed: {response.status_code}")
        except Exception as e:
            print(f"✗ Create account API error: {str(e)}")
        
        print("API test completed!")
        
    except Exception as e:
        print(f"✗ API test failed: {str(e)}")

if __name__ == "__main__":
    test_api()
EOF

# Install requests for API testing
pip3 install requests

# Create a monitoring script
cat > monitor.sh << 'EOF'
#!/bin/bash

echo "=== DynamoDB Account Service Monitor ==="
echo "Timestamp: $(date)"
echo ""

echo "=== EC2 Instance Status ==="
systemctl status account-app --no-pager -l
echo ""

echo "=== Service Logs (last 10 lines) ==="
journalctl -u account-app --no-pager -n 10
echo ""

echo "=== Network Status ==="
netstat -tlnp | grep :8080
echo ""

echo "=== Disk Usage ==="
df -h
echo ""

echo "=== Memory Usage ==="
free -h
echo ""

echo "=== Running the DynamoDB test ==="
cd /opt/dynamodb-test
python3 test_dynamodb.py
echo ""

echo "=== Running the API test ==="
python3 test_api.py
EOF

chmod +x monitor.sh

# Create a simple status page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>NoSQL Account Service Status</title>
    <meta http-equiv="refresh" content="30">
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .success { background-color: #d4edda; border: 1px solid #c3e6cb; }
        .error { background-color: #f8d7da; border: 1px solid #f5c6cb; }
        .info { background-color: #d1ecf1; border: 1px solid #bee5eb; }
    </style>
</head>
<body>
    <h1>NoSQL Account Service Status</h1>
    <p>Last updated: <span id="timestamp"></span></p>
    
    <div class="status info">
        <h3>Service Information</h3>
        <p>DynamoDB Table: account-table</p>
        <p>API Endpoint: http://localhost:8080</p>
        <p>Region: ap-northeast-2</p>
    </div>
    
    <div class="status success">
        <h3>Available Endpoints</h3>
        <ul>
            <li>GET /healthcheck - Health check</li>
            <li>POST /create_account - Create new account</li>
            <li>POST /transfer - Transfer money between accounts</li>
            <li>GET /account/{account_id} - Get account information</li>
        </ul>
    </div>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Install Apache for status page
yum install -y httpd
systemctl enable httpd
systemctl start httpd

# Log completion
echo "Bastion setup completed at $(date)" >> /var/log/bastion-setup.log
