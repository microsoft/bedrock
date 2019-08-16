module "azure-provider" {
  source = "../provider"
}

resource "azurerm_resource_group" "keyvault" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = "${var.vault_name}"
  location            = "${azurerm_resource_group.keyvault.location}"
  resource_group_name = "${azurerm_resource_group.keyvault.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku_name = "${var.keyvault_sku}"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${var.service_principal_object_id}"

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete"
    ]

    certificate_permissions = [
      "get",
      "list",
      "update",
      "delete"
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
