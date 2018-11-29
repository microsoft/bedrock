module "infra" {
  source = "../../stacks/cncf"

  grafana_admin_username = "${var.grafana_admin_username}"
  grafana_admin_password = "${var.grafana_admin_password}"
  grafana_dashboard_yaml = "${file("./grafana-dashboards.yaml")}"

  elasticsearch_master_storage_class = "managed-premium"
  elasticsearch_data_storage_class   = "managed-premium"
  elasticsearch_data_storage_size    = "16Gi"

  prometheus_alertmanager_storage_class = "managed-premium"
  prometheus_server_storage_class       = "managed-premium"
  prometheus_server_storage_size        = "8Gi"

  traefik_ssl_enabled   = "true"
  traefik_ssl_enforced  = "true"
  ingress_replica_count = "3"

  ssl_cert_base64 = "${base64encode(file("./tls/wildcard.domain.com.crt"))}"
  ssl_key_base64  = "${base64encode(file("./tls/wildcard.domain.com.key"))}"
}
