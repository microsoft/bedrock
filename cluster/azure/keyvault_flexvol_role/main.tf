data "azuread_service_principal" "flexvol" {
  application_id = "${var.service_principal_id}"
}

resource "azurerm_role_assignment" "flexvol" {
  count  = "${var.enable_flexvol? 1 : 0}"

  principal_id         = "${data.azuread_service_principal.flexvol.id}"
  role_definition_name = "${var.flexvol_role_assignment_role}"
  scope                = "/subscriptions/${var.subscription_id}/resourcegroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${var.keyvault_name}"
}
