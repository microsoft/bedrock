resource "null_resource" "download_istio" {
  provisioner "local-exec" {
    command = "curl -sL https://github.com/istio/istio/releases/download/${var.istio_version}/istio-${var.istio_version}-linux.tar.gz | tar xz -C ${path.module}"
  }
}

resource "helm_release" "istio" {
  chart     = "${path.module}/istio-${var.istio_version}/install/kubernetes/helm/istio"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  timeout   = "${var.helm_install_timeout}"

  set {
    name  = "global.controlPlaneSecurityEnabled"
    value = "true"
  }

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "kiali.enabled"
    value = "true"
  }

  set {
    name  = "tracing.enabled"
    value = "true"
  }

  depends_on = ["null_resource.download_istio"]
}
