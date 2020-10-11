output "client_certificate" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate
}

output "kube_config" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.cluster.kube_config_raw
}

output "kube_config_file_path" {
  value = local_file.cluster_credentials.0.filename
}

output "kubeconfig_done" {
  value = join("", local_file.cluster_credentials.*.id)
}

output "resource_id" {
  value = azurerm_kubernetes_cluster.cluster.id
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.cluster.node_resource_group
}

output "kubelet_identity" {
  value = length(azurerm_kubernetes_cluster.cluster.kubelet_identity) > 0 ? azurerm_kubernetes_cluster.cluster.kubelet_identity[0] : null
}

output "system_identity" {
  value = length(azurerm_kubernetes_cluster.cluster.identity) > 0 ? azurerm_kubernetes_cluster.cluster.identity[0] : null
}

output "oms_agent_identity" {
  value = var.oms_agent_enabled ? azurerm_kubernetes_cluster.cluster.addon_profile[0].oms_agent[0].oms_agent_identity[0] : null
}
