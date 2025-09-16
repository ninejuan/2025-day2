#!/bin/bash
yum update -y

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install GitHub CLI on Amazon Linux 2
type gh >/dev/null 2>&1 || {
  rpm -qi gh >/dev/null 2>&1 || {
    curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo -o /etc/yum.repos.d/gh-cli.repo
    yum clean all
    yum install -y gh
  }
}

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd-linux-amd64
mv argocd-linux-amd64 /usr/local/bin/argocd

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

aws eks update-kubeconfig --region ${aws_region} --name ${dev_cluster_name}
aws eks update-kubeconfig --region ${aws_region} --name ${prod_cluster_name}

mkdir -p /home/ec2-user/.kube
cp /root/.kube/config /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube

cat << 'EOF' > /home/ec2-user/setup-argocd-nodeport.sh
#!/bin/bash
echo "Setting up ArgoCD NodePort service..."
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort","ports":[{"port":443,"targetPort":8080,"nodePort":30443}]}}'
echo "ArgoCD NodePort setup completed. Port: 30443"
EOF

chmod +x /home/ec2-user/setup-argocd-nodeport.sh
chown ec2-user:ec2-user /home/ec2-user/setup-argocd-nodeport.sh

cat << 'EOF' > /home/ec2-user/argocd-login.sh
#!/bin/bash
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
argocd login $NODE_IP:30443 --username admin --password $ADMIN_PASSWORD --insecure
echo "ArgoCD login completed. URL: https://$NODE_IP:30443"
echo "Login credentials saved to ~/.argocd/config - will persist across sessions"
EOF

chmod +x /home/ec2-user/argocd-login.sh
chown ec2-user:ec2-user /home/ec2-user/argocd-login.sh

mkdir -p /home/ec2-user/.argocd
chown -R ec2-user:ec2-user /home/ec2-user/.argocd
