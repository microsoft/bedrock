module "infra" {
  source = "../common"

  grafana_admin_username = "${var.grafana_admin_username}"
  grafana_admin_password = "${var.grafana_admin_password}"

  elasticsearch_master_storage_class = "default"
  elasticsearch_data_storage_class   = "default"
  elasticsearch_data_storage_size    = "4Gi"

  prometheus_alertmanager_storage_class = "default"
  prometheus_server_storage_class       = "default"
  prometheus_server_storage_size        = "4Gi"

  traefik_ssl_enabled   = "false"
  traefik_ssl_enforced  = "false"
  ingress_replica_count = "3"
}
