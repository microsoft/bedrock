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

output "cluster_derived_resource_group" {
  value = "MC_${var.resource_group_name}_${var.cluster_name}_${var.resource_group_location}"
}
