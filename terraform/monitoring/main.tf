locals {
  cluster_name  = "microservice-proj"
  namespace     = "default"
  chart_name    = "kube-prometheus-stack"
  chart_repo    = "https://prometheus-community.github.io/helm-charts"
  chart_version = "75.3.0"
  name          = "monitoring"
}

resource "helm_release" "monitoring" {
  chart     = local.chart_name
  name      = local.name
  namespace = local.namespace
  repository = local.chart_repo
  version   = local.chart_version
}