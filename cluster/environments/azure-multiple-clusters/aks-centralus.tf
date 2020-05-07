data "azurerm_resource_group" "centralrg" {
  name     = var.central_resource_group_name
}

# local variable with cluster and location specific
locals {
  central_rg_name                 = data.azurerm_resource_group.centralrg.name
  central_rg_location             = data.azurerm_resource_group.centralrg.location
  central_prefix                  = "${local.central_rg_location}_${var.cluster_name}"
  central_flux_clone_dir          = "${local.central_prefix}_flux"
  central_kubeconfig_filename     = "${local.central_prefix}_kube_config"
  central_ip_address_out_filename = "${local.central_prefix}_ip_address"
}

# Creates central vnet
module "central_vnet" {
  source = "../../azure/vnet"

  resource_group_name     = local.central_rg_name
  vnet_name               = "${local.central_prefix}-vnet"
  address_space           = var.central_address_space

  tags = {
    environment = "azure_multiple_clusters"
  }
}

module "central_subnet" {
  #source = "github.com/microsoft/bedrock?ref=master//cluster/azure/subnet"
  source = "../../../cluster/azure/subnet"

  subnet_name          = ["${local.central_prefix}-snet"]
  vnet_name            = module.central_vnet.vnet_name
  resource_group_name  = local.central_rg_name
  address_prefix       = var.central_subnet_prefixes
}

# Creates central aks cluster, flux, kubediff
module "central_aks_gitops" {
  source = "../../azure/aks-gitops"

  acr_enabled              = var.acr_enabled
  agent_vm_count           = var.agent_vm_count
  agent_vm_size            = var.agent_vm_size
  cluster_name             = "${var.cluster_name}_centralus"
  dns_prefix               = var.dns_prefix
  flux_recreate            = var.flux_recreate
  gc_enabled               = var.gc_enabled
  gitops_ssh_url           = var.gitops_ssh_url
  gitops_ssh_key_path      = var.gitops_ssh_key_path
  gitops_path              = var.gitops_central_path
  gitops_url_branch        = var.gitops_central_url_branch
  gitops_poll_interval     = var.gitops_poll_interval
  gitops_label             = var.gitops_label
  resource_group_name      = local.central_rg_name
  service_cidr             = var.central_service_cidr
  service_principal_id     = var.service_principal_id
  service_principal_secret = var.service_principal_secret
  ssh_public_key           = var.ssh_public_key
  vnet_subnet_id           = tostring(element(module.central_subnet.subnet_ids, 0))
  dns_ip                   = var.central_dns_ip
  docker_cidr              = var.central_docker_cidr
  kubernetes_version       = var.kubernetes_version
  kubeconfig_filename      = local.central_kubeconfig_filename
  oms_agent_enabled        = var.oms_agent_enabled
}

# create a static public ip and associate with traffic manger endpoint
module "central_tm_endpoint" {
  source = "../../azure/tm-endpoint-ip"

  resource_group_name                 = local.central_rg_name
  traffic_manager_resource_group_name = var.traffic_manager_resource_group_name
  traffic_manager_profile_name        = var.traffic_manager_profile_name
  endpoint_name                       = "${local.central_rg_location}_${var.cluster_name}"
  public_ip_name                      = var.cluster_name
  ip_address_out_filename             = local.central_ip_address_out_filename

  tags = {
    environment = "azure_multiple_clusters - ${var.cluster_name} - public ip"
    kubedone    = module.central_aks_gitops.kubeconfig_done
  }
}

# Create a role assignment with Contributor role for AKS client service principal object
#   to join vnet/subnet/ip for load balancer/ingress controller
resource "azurerm_role_assignment" "central_spra" {
  principal_id         = data.azuread_service_principal.sp.id
  role_definition_name = var.aks_client_role_assignment_role
  scope                = data.azurerm_resource_group.centralrg.id
}

# Deploy central keyvault flexvolume
module "central_flex_volume" {
  source = "../../azure/keyvault_flexvol"

  resource_group_name      = data.azurerm_resource_group.keyvault.name
  service_principal_id     = var.service_principal_id
  service_principal_secret = var.service_principal_secret
  tenant_id                = data.azurerm_client_config.current.tenant_id
  keyvault_name            = var.keyvault_name
  kubeconfig_filename      = local.central_kubeconfig_filename

  kubeconfig_complete = module.central_aks_gitops.kubeconfig_done
}
