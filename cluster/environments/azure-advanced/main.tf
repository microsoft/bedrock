# terraform {
#    backend "azurerm" {
#    }
# }

resource "azurerm_resource_group" "clusterrg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "azurerm_resource_group" "vnetrg" {
  name     = "${var.cluster_name}-vnetrg"
  location = "${var.resource_group_location}"
}

module "vnet" {
    source = "../../azure/vnet"

    resource_group_name     = "${azurerm_resource_group.vnetrg.name}"
    resource_group_location = "${azurerm_resource_group.vnetrg.location}"
    subnet_names            = ["${var.cluster_name}-aks-subnet"]
    address_space           = "${var.address_space}"
    subnet_prefixes         = "${var.subnet_prefixes}"
    tags = {
      environment = "azure-advanced"
    }
}

module "aks" {
    source = "../../azure/aks"

    resource_group_name       = "${azurerm_resource_group.clusterrg.name}"
    resource_group_location   = "${var.resource_group_location}"
    cluster_name              = "${var.cluster_name}"
    agent_vm_count            = "${var.agent_vm_count}"
    dns_prefix                = "${var.dns_prefix}"
    vnet_subnet_id            = "${module.vnet.vnet_subnet_ids[0]}"
    ssh_public_key            = "${var.ssh_public_key}"
    service_principal_id      = "${var.service_principal_id}"
    service_principal_secret  = "${var.service_principal_secret}"
    service_cidr             = "${var.service_cidr}"
    dns_ip                   = "${var.dns_ip}"
    docker_cidr              = "${var.docker_cidr}"
    kubeconfig_recreate       = ""
}

module "flux" {
    source = "../../common/flux"
    gitops_ssh_url            = "${var.gitops_ssh_url}"
    gitops_ssh_key            = "${var.gitops_ssh_key}"
    gitops_path               = "${var.gitops_path}"
    flux_recreate             = "${var.flux_recreate}"
    kubeconfig_complete       = "${module.aks.kubeconfig_done}"
    flux_clone_dir            = "${var.cluster_name}-flux"
    acr_enabled               = "${var.acr_enabled}"
    gitops_poll_interval      = "${var.gitops_poll_interval}"
}

module "kubediff" {
    source = "../../common/kubediff"

    kubeconfig_complete       = "${module.aks.kubeconfig_done}"
    gitops_ssh_url            = "${var.gitops_ssh_url}"
}
