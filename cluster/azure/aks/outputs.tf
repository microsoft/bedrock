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

output "aks_user_identity_id" {
  value = azurerm_user_assigned_identity.aks_user_identity.id
}

output "aks_user_identity_principal_id" {
  value = azurerm_user_assigned_identity.aks_user_identity.principal_id
}

output "aks_user_identity_client_id" {
  value = azurerm_user_assigned_identity.aks_user_identity.client_id
}
