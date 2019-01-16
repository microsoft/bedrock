output "prometheus_service_endpoint" {
  value = "${var.name}-server.${var.namespace}.svc.cluster.local"
}
