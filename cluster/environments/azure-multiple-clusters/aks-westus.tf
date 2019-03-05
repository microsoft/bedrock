resource "azurerm_resource_group" "westrg" {
  name     = "${var.west_resource_group_name}"
  location = "${var.west_resource_group_location}"
}

# local variable with cluster and location specific
locals {
  west_rg_name                 = "${azurerm_resource_group.westrg.name}"
  west_rg_location             = "${azurerm_resource_group.westrg.location}"
  west_prefix                  = "${local.west_rg_location}-${var.cluster_name}"
  west_flux_clone_dir          = "${local.west_prefix}-flux"
  west_kubeconfig_filename     = "${local.west_prefix}_kube_config"
  west_ip_address_out_filename = "${local.west_prefix}_ip_address"
}

# Creates vnet
module "west_vnet" {
  source = "../../azure/vnet"

  resource_group_name     = "${local.west_rg_name}"
  resource_group_location = "${local.west_rg_location}"
  subnet_names            = ["${var.cluster_name}-aks-subnet"]

  tags = {
    environment = "azure-multiple-clusters"
  }
}

# Creates aks cluster
module "west_aks" {
  source = "../../azure/aks"

  resource_group_name      = "${local.west_rg_name}"
  resource_group_location  = "${local.west_rg_location}"
  cluster_name             = "${var.cluster_name}-west"
  agent_vm_count           = "${var.agent_vm_count}"
  dns_prefix               = "${var.dns_prefix}"
  vnet_subnet_id           = "${module.west_vnet.vnet_subnet_ids[0]}"
  ssh_public_key           = "${var.ssh_public_key}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  kubeconfig_recreate      = ""
  kubeconfig_filename      = "${local.west_kubeconfig_filename}"
}

# Deploys flux in aks cluster
module "west_flux" {
  source = "../../common/flux"

  gitops_ssh_url      = "${var.gitops_ssh_url}"
  gitops_ssh_key      = "${var.gitops_ssh_key}"
  flux_recreate       = ""
  kubeconfig_complete = "${module.west_aks.kubeconfig_done}"
  kubeconfig_filename = "${local.west_kubeconfig_filename}"
  flux_clone_dir      = "${local.west_flux_clone_dir}"
}

# create a static public ip and associate with traffic manger endpoint 
module "west_tm_endpoint" {
  source = "../../azure/tm-endpoint-ip"

  resource_group_name                 = "${module.west_aks.cluster_derived_resource_group}"
  resource_location                   = "${local.west_rg_location}"
  traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  endpoint_name                       = "${local.west_rg_location}-${var.cluster_name}"
  public_ip_name                      = "${var.cluster_name}"
  ip_address_out_filename             = "${local.west_ip_address_out_filename}"

  tags = {
    environment = "azure-multiple-clusters - ${local.west_prefix} - public ip"
    kubedone = "${module.west_aks.kubeconfig_done}"
  }
}

