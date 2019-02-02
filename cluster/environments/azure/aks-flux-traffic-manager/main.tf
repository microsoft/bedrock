module "provider" {
  source = "../../../templates/providers/azure/default"
}

locals {
  /* resource group information */
  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"

  /* cluster 01 information */
  cluster01_name     = "${var.cluster01_name}"
  cluster01_location = "${var.cluster01_location}"

  /* cluster 01 information */
  cluster02_name     = "${var.cluster02_name}"
  cluster02_location = "${var.cluster02_location}"

  /* network information */
  dns01_prefix         = "${var.dns01_prefix}"
  dns02_prefix         = "${var.dns02_prefix}"
  vnet_address_space   = "${var.vnet_address_space}"
  subnet_address_space = "${var.subnet_address_space}"

  /* aks information */
  agent_vm_count = "${var.agent_vm_count}"
  agent_vm_size  = "${var.agent_vm_size}"

  /* node config */
  admin_user     = "${var.admin_user}"
  ssh_public_key = "${var.ssh_public_key}"

  /* service principal information */
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"

  /* output information */
  output_directory = "${var.output_directory}"

  /* flux information */
  flux_repo_url  = "${var.flux_repo_url}"
  gitops_url     = "${var.gitops_url}"
  gitops_ssh_key = "${var.gitops_ssh_key}"

  /* Global resource group information for Traffic Manager */
  global_resource_group_name = "${var.global_resource_group_name}"

  global_resource_group_location = "${var.global_resource_group_location}"
}

module "aks-flux" "cluster" {
  source = "../../../templates/azure/aks-flux-traffic-manager"

  resource_group_name            = "${local.resource_group_name}"
  resource_group_location        = "${local.resource_group_location}"
  cluster01_name                 = "${local.cluster01_name}"
  cluster01_location             = "${local.cluster01_location}"
  dns01_prefix                   = "${local.dns01_prefix}"
  cluster02_name                 = "${local.cluster02_name}"
  cluster02_location             = "${local.cluster02_location}"
  dns02_prefix                   = "${local.dns02_prefix}"
  vnet_address_space             = "${local.vnet_address_space}"
  subnet_address_space           = "${local.subnet_address_space}"
  agent_vm_count                 = "${local.agent_vm_count}"
  agent_vm_size                  = "${local.agent_vm_size}"
  admin_user                     = "${local.admin_user}"
  ssh_public_key                 = "${local.ssh_public_key}"
  client_id                      = "${local.service_principal_id}"
  client_secret                  = "${local.service_principal_secret}"
  output_directory               = "${local.output_directory}"
  flux_repo_url                  = "${local.flux_repo_url}"
  gitops_url                     = "${local.gitops_url}"
  gitops_ssh_key                 = "${local.gitops_ssh_key}"
  global_resource_group_name     = "${local.global_resource_group_name}"
  global_resource_group_location = "${local.global_resource_group_location}"
}