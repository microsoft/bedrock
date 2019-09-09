data "azurerm_key_vault" "keyvault_access_policy" {
  name                = "${var.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "keyvault" {
  key_vault_id            = "${data.azurerm_key_vault.keyvault_access_policy.id}"

  tenant_id               = "${data.azurerm_client_config.current.tenant_id}"
  object_id               = "${var.service_principal_object_id}"
  key_permissions         = "${var.key_permissions}"
  secret_permissions      = "${var.secret_permissions}"
  certificate_permissions = "${var.certificate_permissions}"
}
