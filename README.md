# Platform Lab

A local Kubernetes platform I build, break, and rebuild to learn.
One command spins up a kind cluster, bootstraps Argo CD, and lets GitOps install everything else from this repo.

```bash
make up && make bootstrap
```

## Why

Most of what I want to learn (policy, service mesh, observability, GitOps) only makes sense on a running cluster.
This repo makes that cluster disposable: `make reset` gives me a clean slate in minutes, and Git is the source of truth for what runs on it.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- `make`

## Quick start

```bash
make up          # create the kind cluster (platform-lab)
make bootstrap   # install Argo CD and apply the root app
make argocd-ui   # print admin password + port-forward to https://localhost:8080
```

Run `make help` to list all targets.

| Target       | What it does                                   |
| ------------ | ---------------------------------------------- |
| `up`         | Create the kind cluster                        |
| `down`       | Delete the cluster                             |
| `reset`      | Delete and recreate the cluster                |
| `status`     | Show cluster info and nodes                    |
| `argocd`     | Install Argo CD                                |
| `bootstrap`  | Install Argo CD and apply `gitops/root.yaml`   |
| `argocd-ui`  | Admin password + port-forward to the UI        |

All `kubectl` commands are pinned to the `kind-platform-lab` context, so they never touch another cluster in your kubeconfig.

## How it works

```
make up ──► kind cluster
make bootstrap ──► Argo CD ──► gitops/root.yaml (app of apps)
                                   │
                                   ▼
                              gitops/apps/*  ──► platform/* (Kyverno, …)
```

1. `make up` creates the cluster from `cluster/kind.yaml`.
2. `make bootstrap` installs Argo CD and applies a single **root Application**.
3. The root app watches `gitops/apps/` and creates every Application or ApplicationSet it finds there.
4. Those apps deploy the components in `platform/`.

To add something new: drop a manifest in `gitops/apps/`, push, and Argo CD syncs it.

> Argo CD reads from GitHub, not your local disk. Changes must be pushed before they reach the cluster.

## Repository layout

```
.
├── Makefile
├── cluster/        # kind cluster config
├── gitops/
│   ├── root.yaml   # app of apps, applied once by `make bootstrap`
│   └── apps/       # Applications and ApplicationSets
├── platform/       # components installed by Argo CD
