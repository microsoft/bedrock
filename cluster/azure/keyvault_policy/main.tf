resource "azurerm_key_vault_access_policy" "keyvault" {
  vault_name          = "${var.vault_name}"
  resource_group_name = "${var.resource_group_name}"

  tenant_id = "${var.tenant_id}"
  object_id = "${var.object_id}"

  key_permissions = "${var.key_permissions}"
  secret_permissions = "${var.secret_permissions}"
}