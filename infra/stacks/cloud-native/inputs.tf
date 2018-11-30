variable "grafana_admin_username" {
  type = "string"
}

variable "grafana_admin_password" {
  type = "string"
}

variable "grafana_dashboard_yaml" {
  type = "string"
}

variable "ingress_replica_count" {
  type = "string"
}

variable "traefik_ssl_enabled" {
  type = "string"
}

variable "traefik_ssl_enforced" {
  type = "string"
}

variable "ssl_cert_base64" {
  type    = "string"
  default = ""
}

variable "ssl_key_base64" {
  type    = "string"
  default = ""
}

variable "prometheus_alertmanager_storage_class" {
  type = "string"
}

variable "prometheus_server_storage_class" {
  type = "string"
}

variable "prometheus_server_storage_size" {
  type = "string"
}

variable "elasticsearch_master_storage_class" {
  type = "string"
}

variable "elasticsearch_data_storage_class" {
  type = "string"
}

variable "elasticsearch_data_storage_size" {
  type = "string"
}
