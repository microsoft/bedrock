module "flex_volume" {
    source = "../../azure/keyvault_flexvol"

    resource_group_name       = "${var.resource_group_name}"
    service_principal_id      = "${var.service_principal_id}"
    service_principal_secret  = "${var.service_principal_secret}"
    tenant_id                 = "${data.azurerm_client_config.current.tenant_id}"
    subscription_id           = "${data.azurerm_client_config.current.subscription_id}"
    keyvault_name             = "${module.keyvault.keyvault_name}"
    keyvault_id               = "${module.keyvault.keyvault_id}"
    flexvol_recreate          = "${var.flexvol_recreate}"
    kubeconfig_complete       = "${module.aks.kubeconfig_done}"
}