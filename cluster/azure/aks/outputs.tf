output "client_certificate" {
  sensitive = true
  value = "${azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate}"
}

output "kube_config" {
  sensitive = true
  value = "${azurerm_kubernetes_cluster.cluster.kube_config_raw}"
}

output "kubeconfig_done" {
  value = "${join("",null_resource.cluster_credentials.*.id)}"
}
