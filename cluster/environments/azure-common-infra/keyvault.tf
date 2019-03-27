data "azurerm_client_config" "current" {}

module "keyvault" "keyvault" {
  source = "github.com/Microsoft/bedrock/cluster/azure/keyvault"

  keyvault_name       = "${var.keyvault_name}"
  resource_group_name = "${var.global_resource_group_name}"
  location            = "${var.global_resource_group_location}"
}

module "keyvault_access_policy_default" "default" {
  source = "github.com/Microsoft/bedrock/cluster/azure/keyvault_policy"

  vault_name          = "${module.keyvault.keyvault_name}"
  resource_group_name = "${var.global_resource_group_name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  object_id           = "${data.azurerm_client_config.current.service_principal_object_id}"
}

module "keyvault_access_policy_aks" "aks" {
  source = "github.com/Microsoft/bedrock/cluster/azure/keyvault_policy"

  vault_name          = "${module.keyvault.keyvault_name}"
  resource_group_name = "${var.global_resource_group_name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  object_id           = "${var.service_principal_id}"
  key_permissions     = ["get"]
  secret_permissions  = ["get"]
}
