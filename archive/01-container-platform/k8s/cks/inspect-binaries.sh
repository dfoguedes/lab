curl -LO https://dl.k8s.io/release/v1.23.5/bin/linux/amd64/kubectl
curl -LO https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubeadm
curl -LO https://dl.k8s.io/release/v1.23.5/bin/linux/amd64/kubelet

# Verify the downloaded binaries
curl -LO "https://dl.k8s.io/release/v1.23.5/bin/linux/amd64/kubectl.sha256"
curl -LO "https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubeadm.sha256"
curl -LO "https://dl.k8s.io/release/v1.23.5/bin/linux/amd64/kubelet.sha256"

# Verify if the checksums match
# echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
# echo "$(cat kubeadm.sha256)  kubeadm" | sha256sum --check
# echo "$(cat kubelet.sha256)  kubelet" | sha256sum --check