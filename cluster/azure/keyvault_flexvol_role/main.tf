data "azurerm_key_vault" "flexvol" {
  name                = "${var.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"
}

resource "null_resource" "flexvol_role" {
  provisioner "local-exec" {
    command = "az role assignment create --role ${var.flexvol_role_assignment_role} --assignee ${var.service_principal_id} --scope ${data.azurerm_key_vault.flexvol.id}"
  }

  triggers = {
    precursor_done = "${var.precursor_done}"
  }
}