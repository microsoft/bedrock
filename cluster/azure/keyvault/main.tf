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

    key_permissions = [
    ]

    secret_permissions = [
      "delete",
      "get",
      "set"
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags {
    environment = "Production"
  }
}
/*
resource "azurerm_key_vault_secret" "keyvault" {
  name      = "${var.secret_name}"
  value     = "${var.secret_value}"
  vault_uri = "${azurerm_key_vault.keyvault.vault_uri}"
}
*/
