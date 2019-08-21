terraform {
  backend "azurerm" {}
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "cluster_rg" {
  name     = "${var.resource_group_name}"
}

data "azurerm_resource_group" "keyvault" {
  name     = "${var.keyvault_resource_group}"
}

data "azurerm_subnet" "vnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${data.azurerm_resource_group.keyvault.name}"
}

module "aks-gitops" {
  source = "github.com/microsoft/bedrock?ref=0.12.0//cluster/azure/aks-gitops"

  acr_enabled              = "${var.acr_enabled}"
  agent_vm_count           = "${var.agent_vm_count}"
  agent_vm_size            = "${var.agent_vm_size}"
  cluster_name             = "${var.cluster_name}"
  dns_prefix               = "${var.dns_prefix}"
  flux_recreate            = "${var.flux_recreate}"
  kubeconfig_recreate      = "${var.kubeconfig_recreate}"
  gc_enabled               = "${var.gc_enabled}"
  gitops_ssh_url           = "${var.gitops_ssh_url}"
  gitops_ssh_key           = "${var.gitops_ssh_key}"
  gitops_path              = "${var.gitops_path}"
  gitops_poll_interval     = "${var.gitops_poll_interval}"
  gitops_url_branch        = "${var.gitops_url_branch}"
  resource_group_name      = "${data.azurerm_resource_group.cluster_rg.name}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  ssh_public_key           = "${var.ssh_public_key}"
  vnet_subnet_id           = "${data.azurerm_subnet.vnet.id}"
  network_policy           = "${var.network_policy}"
  oms_agent_enabled        = "${var.oms_agent_enabled}"
}

# Create Azure Key Vault role for SP
module "keyvault_flexvolume_role" {
  source = "github.com/microsoft/bedrock?ref=0.12.0//cluster/azure/keyvault_flexvol_role"

  resource_group_name  = "${data.azurerm_resource_group.keyvault.name}"
  service_principal_id = "${var.service_principal_id}"
  subscription_id      = "${data.azurerm_client_config.current.subscription_id}"
  keyvault_name        = "${var.keyvault_name}"
}

# Deploy central keyvault flexvolume
module "flex_volume" {
  source = "github.com/microsoft/bedrock?ref=0.12.0//cluster/azure/keyvault_flexvol"

  resource_group_name      = "${data.azurerm_resource_group.keyvault.name}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  tenant_id                = "${data.azurerm_client_config.current.tenant_id}"
  keyvault_name            = "${var.keyvault_name}"

  kubeconfig_complete = "${module.aks-gitops.kubeconfig_done}"
}
