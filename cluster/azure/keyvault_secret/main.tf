resource "azurerm_key_vault_secret" "keyvault" {
  count = var.secret_name == "" ? 0 : 1

  name      = var.secret_name
  value     = var.secret_value
  vault_uri = var.vault_uri

  tags = var.tags
}
