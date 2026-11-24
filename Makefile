CLUSTER_NAME := platform-lab
CTX          := kind-$(CLUSTER_NAME)
KUBECTL      := kubectl --context $(CTX)


.PHONY: up down status
u com Succeeded e o rollout do kube-state-metrics foi concluído. Agora verifico se a métrica kube_namespace_annotations já existe, e se alguma namespace tem a anotação de owner.
up:
	kind create cluster \
		--name $(CLUSTER_NAME) \
		--config cluster/kind.yaml

down:
	kind delete cluster \
		--name $(CLUSTER_NAME)

status:
	kubectl cluster-info \
		--context kind-$(CLUSTER_NAME)
	kubectl get nodes

argocd:
	kubectl create namespace argocd
	$(KUBECTL) apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	$(KUBECTL) -n argocd rollout status deploy/argocd-server --timeout=180s

reset: down up
