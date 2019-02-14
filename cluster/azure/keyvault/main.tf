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

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.service_principal_object_id}"

  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags {
    environment = "Production"
  }
}

module "keyvault_access_policy" "keyvault" {
  source              = "./keyvault_policy"

  vault_name          = "${azurerm_key_vault.keyvault.name}"
  resource_group_name = "${azurerm_key_vault.keyvault.resource_group_name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  object_id           = "${data.azurerm_client_config.current.service_principal_object_id}"
}