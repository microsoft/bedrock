resource "azurerm_resource_group" "centralrg" {
  name     = "${var.central_resource_group_name}"
  location = "${var.central_resource_group_location}"
}

# local variable with cluster and location specific
locals {
  central_rg_name                 = "${azurerm_resource_group.centralrg.name}"
  central_rg_location             = "${azurerm_resource_group.centralrg.location}"
  central_prefix                  = "${local.central_rg_location}-${var.cluster_name}"
  central_flux_clone_dir          = "${local.central_prefix}-flux"
  central_kubeconfig_filename     = "${local.central_prefix}_kube_config"
  central_ip_address_out_filename = "${local.central_prefix}_ip_address"
}

# Creates vnet
module "central_vnet" {
  source = "../../azure/vnet"

  resource_group_name     = "${local.central_rg_name }"
  resource_group_location = "${local.central_rg_location}"
  subnet_names            = ["${var.cluster_name}-aks-subnet"]

  tags = {
    environment = "azure-multiple-clusters"
  }
}

# Creates aks cluster
module "central_aks" {
  source = "../../azure/aks"

  resource_group_name      = "${local.central_rg_name }"
  resource_group_location  = "${local.central_rg_location}"
  cluster_name             = "${var.cluster_name}-central"
  agent_vm_count           = "${var.agent_vm_count}"
  dns_prefix               = "${var.dns_prefix}"
  vnet_subnet_id           = "${module.central_vnet.vnet_subnet_ids[0]}"
  ssh_public_key           = "${var.ssh_public_key}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  kubeconfig_recreate      = ""
  kubeconfig_filename      = "${local.central_kubeconfig_filename}"
}

# Deploys flux in aks cluster
module "central_flux" {
  source = "../../common/flux"

  gitops_ssh_url      = "${var.gitops_ssh_url}"
  gitops_ssh_key      = "${var.gitops_ssh_key}"
  flux_recreate       = ""
  kubeconfig_complete = "${module.central_aks.kubeconfig_done}"
  kubeconfig_filename = "${local.central_kubeconfig_filename}"
  flux_clone_dir      = "${local.central_flux_clone_dir}"
}

# create a static public ip and associate with traffic manger endpoint 
module "central_tm_endpoint" {
  source = "../../azure/tm-endpoint-ip"

  resource_group_name                 = "${var.service_principal_is_owner == "1" ? local.central_rg_name : module.central_aks.cluster_derived_resource_group}"
  resource_location                   = "${local.central_rg_location}"
  traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
  traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
  endpoint_name                       = "${local.central_rg_location}-${var.cluster_name}"
  public_ip_name                      = "${var.cluster_name}"
  ip_address_out_filename             = "${local.central_ip_address_out_filename}"

  tags = {
    environment = "azure-multiple-clusters - ${var.cluster_name} - public ip"
    kubedone = "${module.central_aks.kubeconfig_done}"
  }
}

# Create a role assignment with Contributor role for AKS client service principal object
#   to join vnet/subnet/ip for load balancer/ingress controller
resource "azurerm_role_assignment" "central_spra" {
  count                = "${var.service_principal_is_owner == "1" ? 1 : 0}"
  principal_id         = "${data.azuread_service_principal.sp.id}"
  role_definition_name = "${var.aks_client_role_assignment_role}"
  scope                = "${azurerm_resource_group.centralrg.id}"
}
