data "template_file" "template_grafana_yaml" {
  template = "${file("${path.module}/grafana.yaml.tmpl")}"

  vars {
    dashboard_yaml              = "${var.dashboard_yaml}"
    persistence_enabled         = "${var.persistence_enabled}"
    prometheus_service_endpoint = "${var.prometheus_service_endpoint}"
    storage_class               = "${var.storage_class}"
    storage_size                = "${var.storage_size}"
  }
}

resource "null_resource" "generate_grafana_yaml" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.template_grafana_yaml.rendered}' > ${path.module}/grafana.yaml"
  }
}

resource "helm_release" "grafana" {
  chart     = "stable/grafana"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  timeout   = "${var.helm_install_timeout}"

  values = [
    "${file("${path.module}/grafana.yaml")}",
  ]

  set {
    name  = "adminUser"
    value = "${var.admin_user}"
  }

  set {
    name  = "adminPassword"
    value = "${var.admin_password}"
  }

  set {
    name  = "persistance_enabled"
    value = "${var.persistence_enabled}"
  }

  set {
    name  = "persistance_storage_class"
    value = "${var.storage_class}"
  }
}
