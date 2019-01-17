module "resource_group" {
  source = "../../modules/general/resource_group"

  /* resource group settings */
  resource_group_name = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
}

module "vnet" {
  source = "../../modules/network/vnet"

  cluster_name = "${var.cluster_name}"
  vnet_address_space = "${var.vnet_address_space}"
  cluster_location = "${module.resource_group.location}"
  resource_group_name = "${module.resource_group.name}"
}

module "subnet" {
  source = "../../modules/network/subnet"

  cluster_name         = "${var.cluster_name}"
  resource_group_name  = "${module.resource_group.name}"
  subnet_address_space = "${var.subnet_address_space}"
  virtual_network_name = "${module.vnet.vnet_name}"
}

module "aks" {
  source = "../../modules/container/aks"

  cluster_name            = "${var.cluster_name}"
  resource_group_location = "${module.resource_group.location}"
  resource_group_name     = "${module.resource_group.name}"
  dns_prefix              = "${var.cluster_name}"
  admin_user              = "${var.admin_user}"
  ssh_public_key          = "${var.ssh_public_key}"
  agent_vm_count          = "${var.agent_vm_count}"
  agent_vm_size           = "${var.agent_vm_size}"
  vnet_subnet_id          = "${module.subnet.id}"
  client_id               = "${var.client_id}"
  client_secret           = "${var.client_secret}"
}

resource "null_resource" "cluster_credentials" {
  provisioner "local-exec" {
    command = "if [ ! -e ${var.output_directory} ]; then mkdir -p ${var.output_directory}; fi && echo \"${module.aks.kube_config}\" > ${var.output_directory}/kube_config"
  }
}

resource "null_resource" "deploy_flux" {
  provisioner "local-exec" {
    command = "KUBECONFIG=${var.output_directory}/kube_config ${path.module}/deploy-flux.sh -f ${var.flux_repo_url} -g ${var.gitops_url} -k ${var.gitops_ssh_key}"
  }

  depends_on = ["null_resource.cluster_credentials"]
}