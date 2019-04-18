output "kubeconfig_done" {
  value = "${module.aks.kubeconfig_done}"
}

output "cluster_derived_resource_group" {
  value = "${azurerm_kubernetes_cluster.cluster.node_resource_group}"
}