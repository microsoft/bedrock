#terraform {
#  backend "azurerm" {}
#}
module "provider" {
  #source = "github.com/microsoft/bedrock?ref=master//cluster/azure/provider"
  source = "../../../cluster/azure/provider"
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "cluster_rg" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "keyvault" {
  name = var.keyvault_resource_group
}

module "subnet" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/subnet"

  subnet_name          = [var.subnet_name]
  vnet_name            = var.vnet_name
  resource_group_name  = data.azurerm_resource_group.keyvault.name
  address_prefix       = [var.subnet_prefix]
}

module "aks-gitops" {
  #source = "github.com/microsoft/bedrock?ref=master//cluster/azure/aks-gitops"
  source = "../../../cluster/azure/aks-gitops"

  acr_enabled              = var.acr_enabled
  agent_vm_count           = var.agent_vm_count
  agent_vm_size            = var.agent_vm_size
  cluster_name             = var.cluster_name
  dns_prefix               = var.dns_prefix
  flux_recreate            = var.flux_recreate
  gc_enabled               = var.gc_enabled
  gitops_ssh_url           = var.gitops_ssh_url
  gitops_ssh_key           = var.gitops_ssh_key
  gitops_path              = var.gitops_path
  gitops_poll_interval     = var.gitops_poll_interval
  gitops_label             = var.gitops_label
  gitops_url_branch        = var.gitops_url_branch
  kubernetes_version       = var.kubernetes_version
  resource_group_name      = data.azurerm_resource_group.cluster_rg.name
  service_principal_id     = var.service_principal_id
  service_principal_secret = var.service_principal_secret
  ssh_public_key           = var.ssh_public_key
  vnet_subnet_id           = element(module.subnet.subnet_ids, 0)
  network_plugin           = var.network_plugin
  network_policy           = var.network_policy
  oms_agent_enabled        = var.oms_agent_enabled
}

# Create Azure Key Vault role for SP
module "keyvault_flexvolume_role" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/keyvault_flexvol_role"

  resource_group_name  = data.azurerm_resource_group.keyvault.name
  service_principal_id = var.service_principal_id
  subscription_id      = data.azurerm_client_config.current.subscription_id
  keyvault_name        = var.keyvault_name
}

# Deploy central keyvault flexvolume
module "flex_volume" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/keyvault_flexvol"

  resource_group_name      = data.azurerm_resource_group.keyvault.name
  service_principal_id     = var.service_principal_id
  service_principal_secret = var.service_principal_secret
  tenant_id                = data.azurerm_client_config.current.tenant_id
  keyvault_name            = var.keyvault_name

  kubeconfig_complete = module.aks-gitops.kubeconfig_done
}
