resource "kubernetes_namespace" "services_namespace" {
  metadata {
    name = "services"
  }
}
