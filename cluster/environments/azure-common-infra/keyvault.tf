data "azurerm_client_config" "current" {}

module "keyvault" {
  source = "github.com/microsoft/bedrock?ref=0.12support//cluster/azure/keyvault"

  keyvault_name       = "${var.keyvault_name}"
  resource_group_name = "${var.global_resource_group_name}"
  location            = "${var.global_resource_group_location}"
}

module "keyvault_access_policy_default" {
  source = "github.com/microsoft/bedrock?ref=0.12support//cluster/azure/keyvault_policy"

  vault_id  = "${module.keyvault.keyvault_id}"
  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  object_id = "${data.azurerm_client_config.current.service_principal_object_id}"
}

module "keyvault_access_policy_aks" {
  source = "github.com/microsoft/bedrock?ref=0.12support//cluster/azure/keyvault_policy"

  vault_id           = "${module.keyvault.keyvault_id}"
  tenant_id          = "${data.azurerm_client_config.current.tenant_id}"
  object_id          = "${var.service_principal_id}"
  key_permissions    = ["get"]
  secret_permissions = ["get"]
}
