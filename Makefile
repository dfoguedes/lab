CLUSTER_NAME := platform-lab

.PHONY: up down status

up:
	kind create cluster \
		--name $(CLUSTER_NAME) \
		--config kind/cluster.yaml

down:
	kind delete cluster \
		--name $(CLUSTER_NAME)

status:
	kubectl cluster-info \
		--context kind-$(CLUSTER_NAME)
	kubectl get nodes

