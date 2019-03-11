data "azurerm_client_config" "current" {}

module "keyvault" "keyvault" {
    source              = "../../azure/keyvault"

    keyvault_name       = "${var.keyvault_name}" 
    resource_group_name = "${var.resource_group_name}"
    location            = "${var.resource_group_location}"
}

module "keyvault_access_policy_default" "default" {
  source              = "../../azure/keyvault_policy"

  vault_name          = "${module.keyvault.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  object_id           = "${data.azurerm_client_config.current.service_principal_object_id}"
}

module "keyvault_access_policy_aks" "aks" {
  source              = "../../azure/keyvault_policy"

  vault_name          = "${module.keyvault.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  object_id           = "${var.service_principal_id}"
  key_permissions     = ["get"]
  secret_permissions  = ["get"]
}

module "keyvault_secret" "sample" {
    source            = "../../azure/keyvault_secret"

    vault_uri         = "${module.keyvault.keyvault_uri}"
    secret_name       = "${var.secret_name}"
    secret_value      = "${var.secret_value}"
}
