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

output "msi_principal_id" {
  value = azurerm_kubernetes_cluster.cluster.identity.principal_id
}

output "msi_tenant_id" {
  value = azurerm_kubernetes_cluster.cluster.identity.tenant_id
}