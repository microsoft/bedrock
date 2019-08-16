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
  sku_name            = "${var.keyvault_sku}"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

resource "null_resource" "keyvault_reader" {
  count = "${var.vault_reader_identity != "" && var.vault_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/ensure_vault_reader.sh -v ${var.vault_name} -n ${var.vault_reader_identity} -g ${var.resource_group_name} -a ${var.aks_cluster_resource_group_name} -c ${var.aks_cluster_name} -l ${var.aks_cluster_location}"
  }

  triggers = {
    vault_reader_identity = "${var.vault_reader_identity}"
    vault_name            = "${var.vault_name}"
  }

  depends_on = ["azurerm_key_vault.keyvault"]
}
