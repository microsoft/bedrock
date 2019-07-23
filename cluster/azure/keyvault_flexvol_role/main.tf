data "azurerm_key_vault" "flexvol" {
  name                = "${var.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_role_assignment" "flexvol" {
  count = "${var.enable_flexvol? 1 : 0}"

  principal_id         = "${var.service_principal_object_id}"
  role_definition_name = "${var.flexvol_role_assignment_role}"
  scope                = "${data.azurerm_key_vault.flexvol.id}"
}
