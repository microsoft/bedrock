resource "helm_release" "fluentd" {
  chart     = "stable/fluentd-elasticsearch"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  timeout   = "${var.helm_install_timeout}"

  set {
    name  = "elasticsearch.host"
    value = "${var.elasticsearch_client_endpoint}"
  }
}
