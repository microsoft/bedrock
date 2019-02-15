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
    name = "standard"
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags {
    environment = "Production"
  }
}
