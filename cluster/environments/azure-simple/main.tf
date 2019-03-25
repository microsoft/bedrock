terraform {
  backend "azurerm" {}
}

module "aks-gitops" {
  source = "github.com/timfpark/bedrock//cluster/azure/aks-gitops?ref=aks_gitops"

  acr_enabled              = "${var.acr_enabled}"
  agent_vm_count           = "${var.agent_vm_count}"
  agent_vm_size            = "${var.agent_vm_size}"
  cluster_name             = "${var.cluster_name}"
  dns_prefix               = "${var.dns_prefix}"
  flux_recreate            = "${var.flux_recreate}"
  gitops_ssh_url           = "${var.gitops_ssh_url}"
  gitops_ssh_key           = "${var.gitops_ssh_key}"
  gitops_path              = "${var.gitops_path}"
  gitops_poll_interval     = "${var.gitops_poll_interval}"
  resource_group_location  = "${var.resource_group_location}"
  resource_group_name      = "${var.resource_group_name}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  ssh_public_key           = "${var.ssh_public_key}"
  vnet_subnet_id           = "${var.vnet_subnet_id}"
}
