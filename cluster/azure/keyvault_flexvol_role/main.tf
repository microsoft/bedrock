data "azurerm_key_vault" "flexvol" {
  name                = "${var.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"
}

module "flexvol_role" {
  source = "../role_assignment"

  role_assignment_role = "${var.flexvol_role_assignment_role}"
  role_assignee = "${var.service_principal_id}"
  role_scope = "${data.azurerm_key_vault.flexvol.id}"
  precursor_done = "${var.precursor_done}"
}