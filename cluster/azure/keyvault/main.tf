module "azure-provider" {
  source = "../provider"
}

data "azurerm_resource_group" "keyvault" {
  name     = "${var.resource_group_name}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = "${var.keyvault_name}"
  location            = "${data.azurerm_resource_group.keyvault.location}"
  resource_group_name = "${data.azurerm_resource_group.keyvault.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "${var.keyvault_sku}"
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}
