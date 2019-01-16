resource "helm_repository" "incubator" {
  name = "incubator"
  url  = "http://storage.googleapis.com/kubernetes-charts-incubator"
}

resource "helm_release" "jaeger" {
  chart     = "incubator/jaeger"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  timeout   = "${var.helm_install_timeout}"

  set {
    name  = "tag"
    value = "1.8.0"
  }

  set {
    name  = "provisionDataStore.cassandra"
    value = "false"
  }

  set {
    name  = "provisionDataStore.elasticsearch"
    value = "false"
  }

  set {
    name  = "storage.type"
    value = "elasticsearch"
  }

  set {
    name  = "storage.elasticsearch.host"
    value = "${var.elasticsearch_client_endpoint}"
  }

  set {
    name  = "storage.elasticsearch.port"
    value = "${var.elasticsearch_port}"
  }
}
