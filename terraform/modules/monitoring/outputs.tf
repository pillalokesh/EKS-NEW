output "monitoring_namespace" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_release_name" {
  value = helm_release.kube_prometheus_stack.name
}
