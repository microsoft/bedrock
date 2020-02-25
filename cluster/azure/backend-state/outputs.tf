output "storage-account-name" {
  value = azurerm_storage_account.remote_state_sa.name
}

output "resource-group-name" {
  value = azurerm_resource_group.remote_state_rg.name
}

output "container-name" {
  value = azurerm_storage_container.terraform_remote_state_container.name
}

output "storage_account_id" {
  value = azurerm_storage_account.remote_state_sa.id
}
