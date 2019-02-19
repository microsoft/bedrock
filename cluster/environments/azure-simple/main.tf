# terraform {
#    backend "azurerm" {
#    }
# }

module "vnet" {
  source = "../../azure/vnet"

  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  location                = "${var.resource_group_location}"
  subnet_names            = ["${var.cluster_name}-aks-subnet"]

  tags = {
    environment = "azure-simple"
  }
}

module "aks" {
  source = "../../azure/aks"

  resource_group_location  = "${var.resource_group_location}"
  resource_group_name      = "${var.resource_group_name}"
  cluster_name             = "${var.cluster_name}"
  agent_vm_count           = "${var.agent_vm_count}"
  dns_prefix               = "${var.dns_prefix}"
  vnet_subnet_id           = "${module.vnet.vnet_subnet_ids[0]}"
  ssh_public_key           = "${var.ssh_public_key}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  kubeconfig_recreate      = ""
}

module "flux" {
  source = "../../common/flux"

  gitops_url          = "${var.gitops_url}"
  gitops_ssh_key      = "${var.gitops_ssh_key}"
  flux_recreate       = ""
  kubeconfig_complete = "${module.aks.kubeconfig_done}"
  flux_clone_dir      = "${var.cluster_name}-flux"
}
