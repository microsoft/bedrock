provider "azurerm" {
  subscription_id = "${var.subscription_id}"
}

data "azurerm_key_vault" "vault" {
  name                = "${var.vault_name}"
  resource_group_name = "${var.key_vault_resource_group_name}"
}

data "azurerm_key_vault_secret" "cosmosDbAuthKey" {
  name         = "${var.cosmos_db_auth_key}"
  key_vault_id = "${data.azurerm_key_vault.vault.id}"
}

data "azurerm_key_vault_secret" "adxClientSecret" {
  name         = "${var.adx_clientSecretName}"
  key_vault_id = "${data.azurerm_key_vault.vault.id}"
}

resource "null_resource" "stop_adf_triggers_command" {
  provisioner "local-exec" {
    command = "pwsh ${path.module}/stop-adf-triggers.ps1 -AdfName ${var.datafactoryName} -ResourceGroupName ${var.resource_group_name}"
  }

  triggers = {
    datafactoryName     = "${var.datafactoryName}"
    resource_group_name = "${var.resource_group_name}"
  }
}

resource "azurerm_template_deployment" "adf_cosmos_to_kusto" {
  name                = "ADF_ARM"
  resource_group_name = "${var.resource_group_name}"
  template_body       = "${file("${path.module}/Onees-AzureDataFactory.Template.json")}"

  parameters = {
    "cosmosDbAccount"    = "${var.cosmos_db_account}"
    "cosmosDbAccountKey" = "${data.azurerm_key_vault_secret.cosmosDbAuthKey.value}"
    "datafactoryName"    = "${var.datafactoryName}"
    "adx_Endpoint"       = "${var.adx_endpoint}"
    "adx_Database"       = "${var.adx_database}"
    "adx_ClientId"       = "${var.adx_clientId}"
    "adx_ClientSecret"   = "${data.azurerm_key_vault_secret.adxClientSecret.value}"
  }

  deployment_mode = "Incremental"

  depends_on = ["null_resource.stop_adf_triggers_command"]
}

resource "null_resource" "start_adf_triggers_command" {
  provisioner "local-exec" {
    command = "pwsh ${path.module}/start-adf-triggers.ps1 -AdfName ${var.datafactoryName} -ResourceGroupName ${var.resource_group_name}"
  }

  depends_on = ["azurerm_template_deployment.adf_cosmos_to_kusto"]

  triggers = {
    datafactoryName     = "${var.datafactoryName}"
    resource_group_name = "${var.resource_group_name}"
  }
}
