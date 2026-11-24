resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# Deploy Grafana using Helm
# ---------------------------------------------------------------------------------------------------------------------
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  # values     = file("${path.module}/manifests/grafana-values.yaml")
  namespace = "observability"
}


# ---------------------------------------------------------------------------------------------------------------------
# Deploy Loki using Helm
# ---------------------------------------------------------------------------------------------------------------------
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  values     = file("${path.module}/manifests/loki-values.yaml")
  namespace  = "observability"
}

# ---------------------------------------------------------------------------------------------------------------------
# Deploy Tempo using Helm
# ---------------------------------------------------------------------------------------------------------------------
resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  # values     = file("${path.module}/manifests/tempo-values.yaml")
  namespace = "observability"
}
