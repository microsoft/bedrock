module "prometheus" {
  source = "git::https://github.com/timfpark/terraform-helm-prometheus.git"

  prometheus_alertmanager_storage_class = "${var.prometheus_alertmanager_storage_class}"
  prometheus_server_storage_class       = "${var.prometheus_server_storage_class}"
  prometheus_server_storage_size        = "${var.prometheus_server_storage_size}"
}

module "kured" {
  source = "git::https://github.com/timfpark/terraform-helm-kured.git"

  prometheus_service_endpoint = "${module.prometheus.prometheus_service_endpoint}"
}

module "grafana" {
  source = "git::https://github.com/timfpark/terraform-helm-grafana.git"

  admin_user     = "${var.grafana_admin_username}"
  admin_password = "${var.grafana_admin_username}"

  prometheus_service_endpoint = "${module.prometheus.prometheus_service_endpoint}"

  dashboard_yaml = "${file("config/common/grafana-dashboards.yaml")}"
}

module "traefik" {
  source = "git::https://github.com/timfpark/terraform-helm-traefik.git"

  ingress_replica_count = "${var.ingress_replica_count}"

  ssl_enabled        = "${var.traefik_ssl_enabled}"
  ssl_enforced       = "${var.traefik_ssl_enforced}"
  prometheus_enabled = "true"

  ssl_cert_base64 = "${base64encode(file("config/common/tls/wildcard.domain.io.crt"))}"
  ssl_key_base64  = "${base64encode(file("config/common/tls/wildcard.domain.io.key"))}"
}

module "elasticsearch" {
  source = "git::https://github.com/timfpark/terraform-helm-elasticsearch.git"

  elasticsearch_master_storage_class = "${var.elasticsearch_master_storage_class}"
  elasticsearch_data_storage_class   = "${var.elasticsearch_data_storage_class}"
  elasticsearch_data_storage_size    = "${var.elasticsearch_data_storage_size}"
}

module "fluentd" {
  source = "git::https://github.com/timfpark/terraform-helm-fluentd.git"

  elasticsearch_client_endpoint = "${module.elasticsearch.elasticsearch_client_endpoint}"
}

module "kibana" {
  source = "git::https://github.com/timfpark/terraform-helm-kibana.git"

  elasticsearch_client_endpoint = "${module.elasticsearch.elasticsearch_client_endpoint}"
}
