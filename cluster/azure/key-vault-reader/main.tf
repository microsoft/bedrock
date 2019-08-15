module "azure-provider" {
  source = "../provider"
}

resource "azurerm_resource_group" "keyvault" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = "${var.keyvault_name}"
  location            = "${azurerm_resource_group.keyvault.location}"
  resource_group_name = "${azurerm_resource_group.keyvault.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "${var.keyvault_sku}"
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

resource "null_resource" "keyvault_reader" {
  count = "${var.service_principal_name != "" && var.keyvault_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/ensure_vault_reader.sh -v ${var.keyvault_name} -n ${var.service_principal_name} -g ${var.resource_group_name}"
  }

  triggers {
    service_principal_name = "${var.service_principal_name}"
    keyvault_name          = "${var.keyvault_name}"
  }

  depends_on = ["azurerm_key_vault.keyvault"]
}
