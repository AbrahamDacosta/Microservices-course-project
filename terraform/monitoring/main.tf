locals {
  cluster_name  = "course-project"
  namespace     = "default"
  chart_name    = "kube-promotheus-stack"
  chart_repo    = "https://github.com/prometheus-community/helm-charts"
  chart_version = "57.1.1"
  name          = "monitoring"
}

resource "helm-release" "monitoring" {
  chart     = local.chart_name
  name      = local.name
  namespace = local.namespace
  version   = local.chart_version
}