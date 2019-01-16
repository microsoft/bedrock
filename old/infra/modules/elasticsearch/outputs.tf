output "elasticsearch_client_endpoint" {
  value = "${var.name}-client.${var.namespace}.svc.cluster.local"
}
