module "prometheus" {
  source = "../../modules/prometheus"

  prometheus_alertmanager_storage_class = "${var.prometheus_alertmanager_storage_class}"
  prometheus_server_storage_class       = "${var.prometheus_server_storage_class}"
  prometheus_server_storage_size        = "${var.prometheus_server_storage_size}"
}

module "grafana" {
  source = "../../modules/grafana"

  admin_user     = "${var.grafana_admin_username}"
  admin_password = "${var.grafana_admin_password}"

  prometheus_service_endpoint = "${module.prometheus.prometheus_service_endpoint}"

  dashboard_yaml = "${var.grafana_dashboard_yaml}"
}

module "kured" {
  source = "../../modules/kured"

  prometheus_service_endpoint = "${module.prometheus.prometheus_service_endpoint}"
}

module "elasticsearch" {
  source = "../../modules/elasticsearch"

  elasticsearch_master_storage_class = "${var.elasticsearch_master_storage_class}"
  elasticsearch_data_storage_class   = "${var.elasticsearch_data_storage_class}"
  elasticsearch_data_storage_size    = "${var.elasticsearch_data_storage_size}"
}

module "fluentd" {
  source = "../../modules/fluentd"

  elasticsearch_client_endpoint = "${module.elasticsearch.elasticsearch_client_endpoint}"
}

module "kibana" {
  source = "../../modules/kibana"

  elasticsearch_client_endpoint = "${module.elasticsearch.elasticsearch_client_endpoint}"
}

module "jaeger" {
  source = "../../modules/jaeger"

  elasticsearch_client_endpoint = "${module.elasticsearch.elasticsearch_client_endpoint}"
}

module "istio" {
  source = "../../modules/istio"

  kiala_admin_username = "${var.kiala_admin_username}"
  kiala_admin_password = "${var.kiala_admin_password}"

  prometheus_service_endpoint = "${module.prometheus.prometheus_service_endpoint}"
}
