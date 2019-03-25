provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.service_principal_id}"
  client_secret   = "${var.service_principal_secret}"
  tenant_id       = "${var.tenant_id}"
}

# terraform {
#    backend "azurerm" {
#    }
# }

data "azurerm_subscription" "current" {
  subscription_id = "${var.subscription_id}"
}

module "vnet" {
  source = "../../azure/vnet"

  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  subnet_names            = ["${var.cluster_name}-aks-subnet"]
  address_space           = "${var.address_space}"
  subnet_prefixes         = "${var.subnet_prefixes}"

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
  agent_vm_size            = "${var.agent_vm_size}"
  dns_prefix               = "${var.dns_prefix}"
  vnet_subnet_id           = "${module.vnet.vnet_subnet_ids[0]}"
  ssh_public_key           = "${var.ssh_public_key}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  service_CIDR             = "${var.service_CIDR}"
  dns_IP                   = "${var.dns_IP}"
  docker_CIDR              = "${var.docker_CIDR}"
  kubeconfig_recreate      = ""
}

module "flux" {
  source = "../../common/flux"

  gitops_ssh_url      = "${var.gitops_ssh_url}"
  gitops_ssh_key      = "${var.gitops_ssh_key}"
  flux_recreate       = "${var.flux_recreate}"
  kubeconfig_complete = "${module.aks.kubeconfig_done}"
  flux_clone_dir      = "${var.cluster_name}-flux"
  gitops_path            = "${var.gitops_path}"
}

module "kubediff" {
    source = "../../common/kubediff"

    kubeconfig_complete       = "${module.aks.kubeconfig_done}"
    gitops_ssh_url            = "${var.gitops_ssh_url}"
}
