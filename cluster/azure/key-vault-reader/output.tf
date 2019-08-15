output "keyvault_id" {
  description = "The id of the Keyvault"
  value       = "${azurerm_key_vault.keyvault.id}"
}

output "keyvault_uri" {
  description = "The uri of the keyvault"
  value       = "${azurerm_key_vault.keyvault.vault_uri}"
}

output "keyvault_name" {
  description = "The name of the Keyvault"
  value       = "${azurerm_key_vault.keyvault.name}"
}
