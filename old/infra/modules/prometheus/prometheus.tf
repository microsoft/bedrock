resource "helm_release" "prometheus" {
  chart     = "stable/prometheus"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  timeout   = "${var.helm_install_timeout}"

  set {
    name  = "alertmanager.persistentVolume.storageClass"
    value = "${var.prometheus_alertmanager_storage_class}"
  }

  set {
    name  = "server.persistentVolume.storageClass"
    value = "${var.prometheus_server_storage_class}"
  }

  set {
    name  = "server.persistentVolume.size"
    value = "${var.prometheus_server_storage_size}"
  }
}
