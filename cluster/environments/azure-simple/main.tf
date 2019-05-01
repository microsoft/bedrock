module "provider" {
  source = "../../azure/provider"
}

resource "azurerm_resource_group" "cluster_rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

module "vnet" {
  source = "github.com/Microsoft/bedrock/cluster/azure/vnet"

  vnet_name               = "${var.vnet_name}"
  address_space           = "${var.address_space}"
  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  subnet_names            = ["${var.cluster_name}-aks-subnet"]
  subnet_prefixes         = ["${var.subnet_prefixes}"]

  tags = {
    environment = "azure-simple"
  }
}

module "aks-gitops" {
  source = "github.com/Microsoft/bedrock/cluster/azure/aks-gitops"

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
  gitops_url_branch        = "${var.gitops_url_branch}"
  ssh_public_key           = "${var.ssh_public_key}"
  resource_group_location  = "${var.resource_group_location}"
  resource_group_name      = "${azurerm_resource_group.cluster_rg.name}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  vnet_subnet_id           = "${module.vnet.vnet_subnet_ids[0]}"
  service_cidr             = "${var.service_cidr}"
  dns_ip                   = "${var.dns_ip}"
  docker_cidr              = "${var.docker_cidr}"
}
