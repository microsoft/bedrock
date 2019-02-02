output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.cluster.kube_config_raw}"
}

output "aks_cluster_name" {
  value = "${azurerm_kubernetes_cluster.cluster.name}"
}

output "aks_cluster_resource_group_name" {
  value = "${azurerm_resource_group.rg.name}"
}

output "aks_cluster_resource_group_id" {
  value = "${azurerm_resource_group.rg.id}"
}