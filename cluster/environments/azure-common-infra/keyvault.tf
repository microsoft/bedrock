data "azurerm_client_config" "current" {}

module "keyvault" {
  source = "github.com/microsoft/bedrock?ref=byo.rg//cluster/azure/keyvault"

  keyvault_name       = "${var.keyvault_name}"
  resource_group_name = "${data.azurerm_resource_group.global_rg.name}"
}

module "keyvault_access_policy_default" {
  source = "github.com/microsoft/bedrock?ref=byo.rg//cluster/azure/keyvault_policy"

  vault_id  = "${module.keyvault.keyvault_id}"
  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  object_id = "${data.azurerm_client_config.current.service_principal_object_id}"
}

module "keyvault_access_policy_aks" {
  source = "github.com/microsoft/bedrock?ref=byo.rg//cluster/azure/keyvault_policy"

  vault_id           = "${module.keyvault.keyvault_id}"
  tenant_id          = "${data.azurerm_client_config.current.tenant_id}"
  object_id          = "${var.service_principal_id}"
  key_permissions    = ["get"]
  secret_permissions = ["get"]
}
