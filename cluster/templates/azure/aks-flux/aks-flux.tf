module "aks" "cluster" {
  source = "../aks"

  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  cluster_name            = "${var.cluster_name}"
  cluster_location        = "${var.cluster_location}"
  kubernetes_version      = "${var.kubernetes_version}"
  dns_prefix              = "${var.dns_prefix}"
  vnet_address_space      = "${var.vnet_address_space}"
  subnet_address_space    = "${var.subnet_address_space}"
  agent_vm_count          = "${var.agent_vm_count}"
  agent_vm_size           = "${var.agent_vm_size}"
  admin_user              = "${var.admin_user}"
  ssh_public_key          = "${var.ssh_public_key}"
  client_id               = "${var.client_id}"
  client_secret           = "${var.client_secret}"
}

data "template_file" "kubeconfig" {
  template = "$${dirname}/$${clustername}"

  vars {
    dirname = "${var.output_directory}"
    clustername = "${module.aks.aks_cluster_name}_kube_config"
  }
}

output "rendered" {
  value = "${data.template_file.kubeconfig.rendered}"
}

resource "null_resource" "cluster_credentials" {
  provisioner "local-exec" {
    command = "if [ ! -e ${var.output_directory} ]; then mkdir -p ${var.output_directory}; fi && echo \"${module.aks.kube_config}\" > ${data.template_file.kubeconfig.rendered}"
  }
}

resource "null_resource" "deploy_flux" {
  provisioner "local-exec" {
    command = "KUBECONFIG=${data.template_file.kubeconfig.rendered} ${path.module}/deploy_flux.sh -f ${var.flux_repo_url} -g ${var.gitops_url} -k ${var.gitops_ssh_key} -d ${module.aks.aks_cluster_name}-flux"
  }

  depends_on = ["null_resource.cluster_credentials"]
}
