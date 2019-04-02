module "aks" {
  source = "../../azure/aks"

  resource_group_name      = "${var.resource_group_name}"
  resource_group_location  = "${var.resource_group_location}"
  cluster_name             = "${var.cluster_name}"
  agent_vm_count           = "${var.agent_vm_count}"
  agent_vm_size            = "${var.agent_vm_size}"
  dns_prefix               = "${var.dns_prefix}"
  vnet_subnet_id           = "${var.vnet_subnet_id}"
  ssh_public_key           = "${var.ssh_public_key}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  kubeconfig_recreate      = ""
}

module "flux" {
  source = "../../common/flux"

  gitops_ssh_url       = "${var.gitops_ssh_url}"
  gitops_ssh_key       = "${var.gitops_ssh_key}"
  gitops_path          = "${var.gitops_path}"
  gitops_poll_interval = "${var.gitops_poll_interval}"
  flux_recreate        = "${var.flux_recreate}"
  kubeconfig_complete  = "${module.aks.kubeconfig_done}"
  flux_clone_dir       = "${var.cluster_name}-flux"
  acr_enabled          = "${var.acr_enabled}"
}

module "kubediff" {
  source = "../../common/kubediff"

  kubeconfig_complete = "${module.aks.kubeconfig_done}"
  gitops_ssh_url      = "${var.gitops_ssh_url}"
}
