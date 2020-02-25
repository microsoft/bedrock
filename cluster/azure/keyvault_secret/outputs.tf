output "id" {
  value = azurerm_key_vault_secret.keyvault.*.id
}

output "version" {
  value = azurerm_key_vault_secret.keyvault.*.version
}
