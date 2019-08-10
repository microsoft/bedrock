# create the msi
module "pod_identity" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/azure/pod_identity_msi"
  
resource_group_name  = "${data.azurerm_resource_group.global_rg.name}"
  service_principal_id = "${var.service_principal_id}"
  identity_name        = "${var.identity_name}"
}

# give MSI role permission to the keyvault
module "pod_identity_kv_role" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/azure/keyvault_flexvol_role"

  resource_group_name  = "${data.azurerm_resource_group.global_rg.name}"
  keyvault_name        = "${module.keyvault.keyvault_name}"
  service_principal_id = "${module.pod_identity.pod_msi_client_id}"
  subscription_id      = "${data.azurerm_client_config.current.subscription_id}"
  precursor_done       = "${module.keyvault_access_policy_default.id}"
}

# configure MSI access policy to keyvault
module "pod_identy_kv_access" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/azure/keyvault_policy"

  resource_group_name     = "${data.azurerm_resource_group.global_rg.name}"
  keyvault_name           = "${module.keyvault.keyvault_name}"
  service_principal_id    = "${module.pod_identity.pod_msi_client_id}"
  key_permissions         = ["get"]
  secret_permissions      = ["get"]
  certificate_permissions = ["get"]
  precursor_done          = "${module.pod_identity_kv_role.id}"
}
