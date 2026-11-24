#!/bin/bash

# Prerequisites:
# - Docker
# - k3d
# - kubectl

# install k3d with:
# wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
sudo k3d cluster create lab
sudo k3d kubeconfig merge lab --kubeconfig-switch-context
sudo mv /root/.config/k3d/kubeconfig-lab.yaml ~/.kube/config
sudo chmod 607 ~/.kube/config
kubectl get pods
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
OUTPUT=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD initial admin password: $OUTPUT"
kubectl port-forward svc/argocd-server 8080:80 -n argocd & # background argocd-server
argocd login localhost:8081 --username admin --password $OUTPUT --insecure