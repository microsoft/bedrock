# install pod identity support into the cluster
module "pod-identity" {
  source = "../../azure/pod_identity"
  resource_group_name = "${var.keyvault_resource_group}"
  subscription_id     = "${data.azurerm_client_config.current.subscription_id}"
  identity_name       = "${var.identity_name}"
  kubeconfig_complete = "${module.aks-gitops.kubeconfig_done}"
}