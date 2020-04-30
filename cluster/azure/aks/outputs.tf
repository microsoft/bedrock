output "client_certificate" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate
}

output "kube_config" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.cluster.kube_config_raw
}

output "kubeconfig_done" {
  value = join("", local_file.cluster_credentials.*.id)
}

output "resource_id" {
  value = azurerm_kubernetes_cluster.cluster.id
}

output "msi_client_id" {
  value = data.external.msi_object_id.result.msi_client_id
}

output "kubelet_client_id" {
  value = data.external.msi_object_id.result.kubelet_client_id
}

output "kubelet_id" {
  value = data.external.msi_object_id.result.kubelet_id
}

output "node_resource_group" {
  value = data.external.msi_object_id.result.node_resource_group
}

output "kubelet_resource_id" {
  value = data.external.msi_object_id.result.kubelet_resource_id
}
