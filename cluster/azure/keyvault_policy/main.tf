resource "azurerm_key_vault_access_policy" "keyvault" {
  key_vault_id = var.vault_id

  tenant_id = var.tenant_id
  object_id = var.object_id

  key_permissions    = var.key_permissions
  secret_permissions = var.secret_permissions

  # is the module enabled?
  count = var.enabled == true ? 1 : 0
}
