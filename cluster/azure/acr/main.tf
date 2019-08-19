resource "azurerm_container_registry" "acr" {
  name                     = "${var.name}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  sku                      = "Premium"
  admin_enabled            = true
  georeplication_locations = ["${var.location}", "${var.alternate_location}"]
}

resource "null_resource" "store_acr_secrets" {
  count = "${var.name != "" && var.vault_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/add_acr_secret.sh -a ${var.name} -v ${var.vault_name} -n ${var.acr_auth_secret_name} -u ${azurerm_container_registry.acr.admin_username} -p ${azurerm_container_registry.acr.admin_password} -e ${var.email}"
  }

  triggers = {
    name       = "${var.name}"
    vault_name = "${var.vault_name}"
  }

  depends_on = ["azurerm_container_registry.acr"]
}
