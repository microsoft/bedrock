output "aks_kv_identity_id" {
  value = data.azurerm_user_assigned_identity.aks_kv_user_identity.id
}

output "aks_kv_identity_principal_id" {
  value = data.azurerm_user_assigned_identity.aks_kv_user_identity.principal_id
}

output "aks_kv_identity_client_id" {
  value = data.azurerm_user_assigned_identity.aks_kv_user_identity.client_id
}
