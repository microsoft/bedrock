data "azuread_service_principal" "flexvol" {
  application_id = "${var.service_principal_id}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "flexvol" {
  count = var.enable_flexvol && var.service_principal_id != data.azurerm_client_config.current.client_id ? 1 : 0

  principal_id         = "${data.azuread_service_principal.flexvol.id}"
  role_definition_name = "${var.flexvol_role_assignment_role}"
  scope                = "/subscriptions/${var.subscription_id}/resourcegroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${var.keyvault_name}"
}
