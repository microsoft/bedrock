module "provider" {
    source = "../common/azure-provider/default"
}

locals {
  /* resource group information */
  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"

  /* network information */
  vnet_address_space      = "10.200.0.0/16"
  subnet_address_space    = "10.200.0.0/16"

  /* cluster information */
  cluster_name = "${var.cluster_name}"

  /* aks information */
  agent_vm_count            = "3"
  agent_vm_size             = "Standard_DS3_v2"
 
  /* node config */
  admin_user                = "${var.admin_user}"
  ssh_public_key            = "${var.ssh_public_key}"

  /* service principal information */
  service_principal_id      = "${var.service_principal_id}"
  service_principal_secret  = "${var.service_principal_secret}"

  /* output information */
  output_directory          = "${var.output_directory}"
}

module "azure_aks" {
  source = "../../topology/azure-aks-basic"

  resource_group_name       = "${local.resource_group_name}"
  resource_group_location   = "${local.resource_group_location}"
  cluster_name              = "${local.cluster_name}"
  vnet_address_space        = "${local.vnet_address_space}"
  subnet_address_space      = "${local.subnet_address_space}"
  agent_vm_count            = "${local.agent_vm_count}"
  agent_vm_size             = "${local.agent_vm_size}"
  admin_user                = "${local.admin_user}"
  ssh_public_key            = "${local.ssh_public_key}"
  client_id                 = "${local.service_principal_id}"
  client_secret             = "${local.service_principal_secret}"
  output_directory          = "${local.output_directory}"
}
