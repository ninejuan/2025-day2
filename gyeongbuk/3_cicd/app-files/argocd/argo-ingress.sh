#!/bin/bash

kubectl apply -f argo-ingress.yaml

echo "Waiting for ALB to be created..."
timeout=300
while [ $timeout -gt 0 ]; do
  ALB_URL=$(kubectl get ingress product-argo-ingress -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
  if [[ -n "$ALB_URL" && "$ALB_URL" != "null" ]]; then
    echo "ALB URL found: $ALB_URL"
    break
  fi
  echo "Waiting for ALB... ($timeout seconds remaining)"
  sleep 10
  timeout=$((timeout-10))
done

if [[ -z "$ALB_URL" || "$ALB_URL" == "null" ]]; then
  echo "Failed to get ALB URL. Check ingress status:"
  kubectl describe ingress product-argo-ingress -n argocd
  exit 1
fi

kubectl patch configmap argocd-cm -n argocd --type merge -p "{\"data\":{\"url\":\"http://$ALB_URL\"}}"
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment/argocd-server -n argocd

echo "ArgoCD URL: http://$ALB_URL"
echo "Admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"