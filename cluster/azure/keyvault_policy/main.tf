data "azurerm_key_vault" "keyvault_access_policy" {
  name                = "${var.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"
}

resource "null_resource" "keyvault_access_policy" {
  provisioner "local-exec" {
    command = "az keyvault set-policy --name ${data.azurerm_key_vault.keyvault_access_policy.name} --spn ${var.service_principal_id} --resource-group ${var.resource_group_name} --key-permissions ${join(" ", var.key_permissions)} --secret-permissions ${join(" ", var.secret_permissions)} --certificate-permissions ${join(" ", var.certificate_permissions)}"
  }


  triggers = {
    precursor_done = "${var.precursor_done}"
  }
}