module "infra" {
  source = "../../stacks/cloud-native"

  elasticsearch_master_storage_class = "default"
  elasticsearch_data_storage_class   = "default"
  elasticsearch_data_storage_size    = "4Gi"

  grafana_admin_username = "ops"
  grafana_admin_password = "${var.grafana_admin_password}"
  grafana_dashboard_yaml = "${file("./grafana-dashboards.yaml")}"

  kiala_admin_username = "ops"
  kiala_admin_password = "${var.grafana_admin_password}"

  prometheus_alertmanager_storage_class = "default"
  prometheus_server_storage_class       = "default"
  prometheus_server_storage_size        = "4Gi"

  traefik_ssl_enabled   = "false"
  traefik_ssl_enforced  = "false"
  ingress_replica_count = "3"
}
