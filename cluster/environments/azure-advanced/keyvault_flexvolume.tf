module "flex_volume" {
    source = "../../azure/keyvault_flexvol"

    resource_group_name       = "${var.resource_group_name}"
    service_principal_id      = "${var.service_principal_id}"
    service_principal_secret  = "${var.service_principal_secret}"
    subscription_id           = "${var.subscription_id}"
    keyvault_name             = "${module.keyvault.keyvault_name}"
    flexvol_recreate          = "${var.flexvol_recreate}"
    kubeconfig_complete       = "${module.aks.kubeconfig_done}"

}