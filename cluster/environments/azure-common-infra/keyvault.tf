data "azurerm_client_config" "current" {}

module "keyvault" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/azure/keyvault"

  keyvault_name       = "${var.keyvault_name}"
  resource_group_name = "${data.azurerm_resource_group.global_rg.name}"
}

module "keyvault_access_policy_default" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/azure/keyvault_policy"

  keyvault_name = "${module.keyvault.keyvault_name}"
  resource_group_name = "${var.global_resource_group_name}"
  service_principal_id = "${data.azurerm_client_config.current.service_principal_application_id}"
}
