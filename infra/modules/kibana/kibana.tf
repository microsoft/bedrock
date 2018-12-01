data "template_file" "kibana_yaml" {
  template = "${file("${path.module}/kibana.yaml.tmpl")}"

  vars {
    elasticsearch_client_endpoint = "${var.elasticsearch_client_endpoint}"
  }
}

resource "null_resource" "generate_kibana_yaml" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.kibana_yaml.rendered}' > ${path.module}/kibana.yaml"
  }

  depends_on = ["data.template_file.kibana_yaml"]
}

resource "helm_release" "kibana" {
  chart     = "stable/kibana"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  timeout   = "${var.helm_install_timeout}"

  values = [
    "${file("${path.module}/kibana.yaml")}",
  ]

  depends_on = ["null_resource.generate_kibana_yaml"]
}
