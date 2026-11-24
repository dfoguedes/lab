CLUSTER_NAME := platform-lab
CTX          := kind-$(CLUSTER_NAME)
KUBECTL      := kubectl --context $(CTX)


.PHONY: up down status
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

argocd-ui:
		@$(KUBECTL) -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
		$(KUBECTL) -n argocd port-forward svc/argocd-server 8080:443
bootstrap: argocd
	$(KUBECTL) apply -f gitops/root.yaml
reset: down up
