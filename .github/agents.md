# Copilot Coding Agent Instructions

## Repository Overview

This is an engineering lab repository containing reference implementations, experimental architectures, and learning materials across Infrastructure as Code, Kubernetes, Cloud Native tooling, Data & AI Engineering, CI/CD pipelines, and fundamentals.

## Repository Structure

- `00-infrastructure-as-code/` — Terraform (GCP), Bicep (Azure), and Ansible playbooks
- `01-container-platform/` — Docker, Helm charts, and Kubernetes manifests (Istio, CKS, OPA Gatekeeper, Cilium, Prometheus)
- `02-cloud-native-tooling/` — Go programs and Python tools
- `03-data-ai-engineering/` — ML/AI with Vertex AI, BigQuery, Dataflow, and Vision/Language APIs
- `04-ci-cd-pipelines/` — GitHub Actions workflow examples and Jenkins pipelines
- `05-fundamentals/` — Linux kernel and networking topics

## Languages and Technologies

- **Terraform (HCL)**: GCP infrastructure — GKE clusters, networking, serverless
- **Ansible (YAML)**: Server provisioning — K3s, Nginx, Fail2ban, Grafana
- **Go**: CLI tools, load balancers, servers, caching proxies, Azure controllers
- **Python**: AI/ML pipelines, data engineering, YouTube summarizer, Cloud Functions
- **Shell (Bash)**: Automation scripts
- **Kubernetes YAML**: Manifests for deployments, services, network policies, CRDs
- **Helm**: Chart templates in `01-container-platform/helm-charts/`
- **Docker / Docker Compose**: Container images and multi-service stacks
- **Bicep**: Azure infrastructure definitions
- **GitHub Actions / Jenkins**: CI/CD pipeline definitions

## Conventions

- Each project or example is self-contained within its own directory.
- Python dependencies are specified in `requirements.txt` files.
- Go programs are standalone files or small packages without `go.mod` files.
- Terraform projects target GCP and follow a flat module structure.
- Kubernetes manifests are organized by topic (e.g., `istio/`, `cks/`, `cillium/`).
- GitHub Actions workflows in `04-ci-cd-pipelines/gh-actions/` are examples and templates, not active repository CI.

## Documentation Style

- READMEs are practical and code-first, focusing on how to run things.
- Use markdown with code blocks for commands and configuration examples.
- Keep documentation concise and example-driven.
- Place a `README.md` in each project directory that explains its purpose and usage.

## Working with This Repository

- There is no centralized build system — each project builds and runs independently.
- Terraform projects: use `terraform init && terraform plan` within each project directory.
- Go programs: compile and run with `go run` or `go build` within each program's directory.
- Python programs: install dependencies from the local `requirements.txt` and run with `python`.
- Docker projects: use `docker build` or `docker compose up` as described in their READMEs.
- Helm charts: use `helm install` or `helm template` from the chart directory.
- Ansible playbooks: run with `ansible-playbook` against the provided inventories.
