data "azurerm_client_config" "current" {}

module "keyvault" {
  #source = "github.com/Microsoft/bedrock/cluster/azure/keyvault"
  source = "../../azure/keyvault"

  keyvault_name       = "${var.keyvault_name}"
  resource_group_name = "${var.global_resource_group_name}"
  location            = "${var.global_resource_group_location}"
}

module "keyvault_access_policy_default" {
  #source = "github.com/Microsoft/bedrock/cluster/azure/keyvault_policy"
  source = "../../azure/keyvault_policy"

  vault_id  = "${module.keyvault.keyvault_id}"
  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  object_id = "${data.azurerm_client_config.current.service_principal_object_id}"
}

module "keyvault_access_policy_aks" {
  #source = "github.com/Microsoft/bedrock/cluster/azure/keyvault_policy"
  source = "../../azure/keyvault_policy"

  vault_id           = "${module.keyvault.keyvault_id}"
  tenant_id          = "${data.azurerm_client_config.current.tenant_id}"
  object_id          = "${var.service_principal_object_id}"
  key_permissions    = ["get"]
  secret_permissions = ["get"]
}

# add role permissions for the service principal on the keyvault
module "keyvault_flexvolume_role" {
  #source = "github.com/Microsoft/bedrock/cluster/azure/keyvault_flexvol_role"
  source = "../../azure/keyvault_flexvol_role"

  resource_group_name         = "${azurerm_resource_group.global_rg.name}"
  service_principal_object_id = "${var.service_principal_object_id}"
  subscription_id             = "${data.azurerm_client_config.current.subscription_id}"
  keyvault_name               = "${module.keyvault.keyvault_name}"
}
