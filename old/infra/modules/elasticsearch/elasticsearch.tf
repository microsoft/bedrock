resource "helm_release" "elasticsearch" {
  chart     = "stable/elasticsearch"
  name      = "elasticsearch"
  namespace = "elasticsearch"
  timeout   = "${var.helm_install_timeout}"

  set {
    name  = "master.persistence.storageClass"
    value = "${var.elasticsearch_master_storage_class}"
  }

  set {
    name  = "master.persistence.size"
    value = "${var.elasticsearch_master_storage_size}"
  }

  set {
    name  = "data.persistence.storageClass"
    value = "${var.elasticsearch_data_storage_class}"
  }

  set {
    name  = "data.persistence.size"
    value = "${var.elasticsearch_data_storage_size}"
  }
}
