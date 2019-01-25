module "provider" {
    source = "../../../templates/providers/azure/default"
}

locals {
    /* resource group information */
    resource_group_name     = "${var.resource_group_name}"
    resource_group_location = "${var.resource_group_location}"

    /* cluster information */
    cluster_name = "${var.cluster_name}"
    cluster_location = "${var.cluster_location}"

    /* network information */
    dns_prefix              = "${var.dns_prefix}"
    vnet_address_space      = "${var.vnet_address_space}"
    subnet_address_space    = "${var.subnet_address_space}"

    /* aks information */
    agent_vm_count            = "${var.agent_vm_count}"
    agent_vm_size             = "${var.agent_vm_size}"

    /* node config */
    admin_user                = "${var.admin_user}"
    ssh_public_key            = "${var.ssh_public_key}"

    /* service principal information */
    service_principal_id      = "${var.service_principal_id}"
    service_principal_secret  = "${var.service_principal_secret}"

    /* output information */
    output_directory          = "${var.output_directory}"
}

module "aks" "cluster" {
    source = "../../../templates/azure/aks"

    resource_group_name       = "${local.resource_group_name}"
    resource_group_location   = "${local.resource_group_location}"
    cluster_name              = "${local.cluster_name}"
    cluster_location          = "${local.cluster_location}"
    dns_prefix                = "${local.dns_prefix}"
    vnet_address_space        = "${local.vnet_address_space}"
    subnet_address_space      = "${local.subnet_address_space}"
    agent_vm_count            = "${local.agent_vm_count}"
    agent_vm_size             = "${local.agent_vm_size}"
    admin_user                = "${local.admin_user}"
    ssh_public_key            = "${local.ssh_public_key}"
    client_id                 = "${local.service_principal_id}"
    client_secret             = "${local.service_principal_secret}"
}

resource "null_resource" "cluster_credentials" {
  provisioner "local-exec" {
    command = "if [ ! -e ${var.output_directory} ]; then mkdir -p ${var.output_directory}; fi && echo \"${module.aks.kube_config}\" > ${var.output_directory}/kube_config"
  }
}