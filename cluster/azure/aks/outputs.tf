output "client_certificate" {
  sensitive = true
  value = "${azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate}"
}

output "kube_config" {
  sensitive = true
  value = "${azurerm_kubernetes_cluster.cluster.kube_config_raw}"
}

output "depend_id" {
  value = "${azurerm_kubernetes_cluster.cluster.id}"
}