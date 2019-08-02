resource "azurerm_resource_group" "eastrg" {
  name     = "${var.east_resource_group_name}"
  location = "${var.east_resource_group_location}"
}

# local variable with cluster and location specific
locals {
  east_rg_name                 = "${azurerm_resource_group.eastrg.name}"
  east_rg_location             = "${azurerm_resource_group.eastrg.location}"
  east_prefix                  = "${local.east_rg_location}_${var.cluster_name}"
  east_flux_clone_dir          = "${local.east_prefix}_flux"
  east_kubeconfig_filename     = "${local.east_prefix}_kube_config"
  east_ip_address_out_filename = "${local.east_prefix}_ip_address"
}

# Creates east vnet
module "east_vnet" {
  source = "github.com/Microsoft/bedrock?ref=master//cluster/azure/vnet"

  resource_group_name     = "${local.east_rg_name }"
  resource_group_location = "${local.east_rg_location}"
  subnet_names            = ["${var.cluster_name}_aks_subnet"]
  address_space           = "${var.east_address_space}"
  subnet_prefixes         = "${var.east_subnet_prefixes}"

  tags = {
    environment = "azure_multiple_clusters"
  }
}

# Creates east aks cluster, flux, kubediff
module "east_aks_gitops" {
  source = "github.com/Microsoft/bedrock?ref=master//cluster/azure/aks-gitops"

  acr_enabled              = "${var.acr_enabled}"
  agent_vm_count           = "${var.agent_vm_count}"
  agent_vm_size            = "${var.agent_vm_size}"
  cluster_name             = "${var.cluster_name}_eastus"
  dns_prefix               = "${var.dns_prefix}"
  flux_recreate            = "${var.flux_recreate}"
  gc_enabled               = "${var.gc_enabled}"
  gitops_ssh_url           = "${var.gitops_ssh_url}"
  gitops_ssh_key           = "${var.gitops_ssh_key}"
  gitops_path              = "${var.gitops_east_path}"
  gitops_url_branch        = "${var.gitops_east_url_branch}"
  gitops_poll_interval     = "${var.gitops_poll_interval}"
  resource_group_location  = "${var.east_resource_group_location}"
  resource_group_name      = "${azurerm_resource_group.eastrg.name}"
  service_cidr             = "${var.east_service_cidr}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  ssh_public_key           = "${var.ssh_public_key}"
  vnet_subnet_id           = "${module.east_vnet.vnet_subnet_ids[0]}"
  dns_ip                   = "${var.east_dns_ip}"
  docker_cidr              = "${var.east_docker_cidr}"
  kubeconfig_filename      = "${local.east_kubeconfig_filename}"
  oms_agent_enabled        = "${var.oms_agent_enabled}"
}

# create a static public ip and associate with traffic manger endpoint
module "east_tm_endpoint" {
  source = "../../azure/tm-endpoint-ip"

  resource_group_name                 = "${local.east_rg_name}"
  resource_location                   = "${local.east_rg_location}"
  traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  endpoint_name                       = "${local.east_rg_location}_${var.cluster_name}"
  public_ip_name                      = "${var.cluster_name}"
  ip_address_out_filename             = "${local.east_ip_address_out_filename}"

  tags = {
    environment = "azure_multiple_clusters - ${var.cluster_name} - public ip"
    kubedone    = "${module.east_aks_gitops.kubeconfig_done}"
  }
}

# Create a role assignment with Contributor role for AKS client service principal object
#   to join vnet/subnet/ip for load balancer/ingress controller
resource "azurerm_role_assignment" "east_spra" {
  principal_id         = "${data.azuread_service_principal.sp.id}"
  role_definition_name = "${var.aks_client_role_assignment_role}"
  scope                = "${azurerm_resource_group.eastrg.id}"
}

# Deploy east keyvault flexvolume
module "east_flex_volume" {
  source = "github.com/Microsoft/bedrock?ref=master//cluster/azure/keyvault_flexvol"

  resource_group_name      = "${var.keyvault_resource_group}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  tenant_id                = "${data.azurerm_client_config.current.tenant_id}"
  keyvault_name            = "${var.keyvault_name}"
  kubeconfig_filename      = "${local.east_kubeconfig_filename}"

  kubeconfig_complete = "${module.east_aks_gitops.kubeconfig_done}"
}
