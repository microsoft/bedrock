data "azurerm_resource_group" "centralrg" {
  name     = "${var.central_resource_group_name}"
  location = "${var.central_resource_group_location}"
}

# local variable with cluster and location specific
locals {
  central_rg_name                 = "${data.azurerm_resource_group.centralrg.name}"
  central_rg_location             = "${data.azurerm_resource_group.centralrg.location}"
  central_prefix                  = "${local.central_rg_location}-${var.cluster_name}"
  central_flux_clone_dir          = "${local.central_prefix}-flux"
  central_kubeconfig_filename     = "${local.central_prefix}_kube_config"
  central_ip_address_out_filename = "${local.central_prefix}_ip_address"
}

# Creates vnet
module "central_vnet" {
  source = "github.com/microsoft/bedrock?ref=0.12support//cluster/azure/vnet"

  resource_group_name     = "${local.central_rg_name}"

  subnet_names    = ["${var.cluster_name}-aks-subnet"]
  address_space   = "${var.central_address_space}"
  subnet_prefixes = "${var.central_subnet_prefixes}"

  tags = {
    environment = "azure-multiple-clusters-waf-tm-apimgmt"
  }
}

# Creates aks cluster
module "central_aks" {
  source = "github.com/microsoft/bedrock?ref=0.12support//cluster/azure/aks"

  resource_group_name      = "${local.central_rg_name}"
  cluster_name             = "${var.cluster_name}-central"
  agent_vm_count           = "${var.agent_vm_count}"
  dns_prefix               = "${var.dns_prefix}"
  vnet_subnet_id           = "${module.central_vnet.vnet_subnet_ids[0]}"
  service_cidr             = "${var.central_service_cidr}"
  dns_ip                   = "${var.central_dns_ip}"
  docker_cidr              = "${var.central_docker_cidr}"
  ssh_public_key           = "${var.ssh_public_key}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  kubeconfig_recreate      = ""
  kubeconfig_filename      = "${local.central_kubeconfig_filename}"
  oms_agent_enabled        = "${var.oms_agent_enabled}"
}

# Deploys flux in aks cluster
module "central_flux" {
  source = "github.com/microsoft/bedrock?ref=0.12support//cluster/common/flux"

  gitops_ssh_url       = "${var.gitops_ssh_url}"
  gitops_ssh_key       = "${var.gitops_ssh_key}"
  flux_recreate        = ""
  kubeconfig_complete  = "${module.central_aks.kubeconfig_done}"
  kubeconfig_filename  = "${local.central_kubeconfig_filename}"
  flux_clone_dir       = "${local.central_flux_clone_dir}"
  gitops_path          = "${var.gitops_central_path}"
  gitops_poll_interval = "${var.gitops_poll_interval}"
}

module "central_tm_endpoint" {
  source = "github.com/microsoft/bedrock?ref=0.12support//cluster/azure/tm-endpoint-ip"

  resource_group_name                 = "${local.central_rg_name}"
  traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  endpoint_name                       = "${local.central_rg_location}-waf-ipcentral"
  public_ip_name                      = "${var.cluster_name}-waf-ipcentral"
  ip_address_out_filename             = "${local.central_ip_address_out_filename}"
  allocation_method                   = "Dynamic"

  tags = {
    environment = "azure-multiple-clusters-waf-tm-apimgmt - ${var.cluster_name} - public ip"
  }
}

# Create a role assignment with Contributor role for AKS client service principal object
#   to join vnet/subnet/ip for load balancer/ingress controller
resource "azurerm_role_assignment" "central_spra" {
  count                = "${var.service_principal_is_owner == "1" ? 1 : 0}"
  principal_id         = "${data.azuread_service_principal.sp.id}"
  role_definition_name = "${var.aks_client_role_assignment_role}"
  scope                = "${data.azurerm_resource_group.centralrg.id}"
}
