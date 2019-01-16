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
    name  = "kiali.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.enabled"
    value = "false"
  }

  set {
    name  = "servicegraph.prometheusAddr"
    value = "http://${var.prometheus_service_endpoint}:9090"
  }

  set {
    name  = "mtls.enabled"
    value = "true"
  }

  set {
    name  = "kiali.dashboard.username"
    value = "${var.kiala_admin_username}"
  }

  set {
    name  = "kiali.dashboard.passphrase"
    value = "${var.kiala_admin_password}"
  }

  set {
    name  = "tracing.enabled"
    value = "true"
  }

  depends_on = ["null_resource.download_istio"]
}

resource "null_resource" "install_default_gateway" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/gateway.yaml"
  }

  depends_on = ["helm_release.istio"]
}
