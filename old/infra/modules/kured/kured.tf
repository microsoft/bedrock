resource "helm_release" "kured" {
  chart     = "stable/kured"
  name      = "kured"
  namespace = "kube-system"
  timeout   = "${var.helm_install_timeout}"

  set {
    name  = "extraArgs.prometheus-url"
    value = "http://${var.prometheus_service_endpoint}"
  }
}
