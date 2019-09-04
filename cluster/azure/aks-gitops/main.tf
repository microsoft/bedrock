data "azurerm_resource_group" "aksgitops" {
  name = "${var.resource_group_name}"
}

module "aks" {
  source = "../../azure/aks"

  resource_group_name             = "${var.resource_group_name}"
  cluster_name                    = "${var.cluster_name}"
  agent_vm_count                  = "${var.agent_vm_count}"
  agent_vm_size                   = "${var.agent_vm_size}"
  dns_prefix                      = "${var.dns_prefix}"
  ssh_public_key                  = "${var.ssh_public_key}"
  service_principal_id            = "${var.service_principal_id}"
  service_principal_secret        = "${var.service_principal_secret}"
  server_app_id                   = "${var.server_app_id}"
  server_app_secret               = "${var.server_app_secret}"
  client_app_id                   = "${var.client_app_id}"
  tenant_id                       = "${var.tenant_id}"
  service_cidr                    = "${var.service_cidr}"
  dns_ip                          = "${var.dns_ip}"
  docker_cidr                     = "${var.docker_cidr}"
  kubeconfig_recreate             = "${var.kubeconfig_recreate}"
  kubeconfig_filename             = "${var.kubeconfig_filename}"
  kubeconfigadmin_filename        = "${var.kubeconfigadmin_filename}"
  oms_agent_enabled               = "${var.oms_agent_enabled}"
  enable_http_application_routing = "${var.enable_http_application_routing}"
  enable_azure_monitoring         = "${var.enable_azure_monitoring}"
  enable_dev_spaces               = "${var.enable_dev_spaces}"
  space_name                      = "${var.space_name}"
}

module "flux" {
  source = "../../common/flux"

  gitops_ssh_url            = "${var.gitops_ssh_url}"
  gitops_ssh_key            = "${var.gitops_ssh_key}"
  gitops_path               = "${var.gitops_path}"
  gitops_poll_interval      = "${var.gitops_poll_interval}"
  gitops_url_branch         = "${var.gitops_url_branch}"
  enable_flux               = "${var.enable_flux}"
  flux_recreate             = "${var.flux_recreate}"
  kubeconfig_complete       = "${module.aks.kubeconfig_done}"
  kubeconfigadmin_done      = "${module.aks.kubeconfigadmin_done}"
  kubeconfig_filename       = "${var.kubeconfig_filename}"
  kubeconfigadmin_filename  = "${var.kubeconfigadmin_filename}"
  flux_clone_dir            = "${var.cluster_name}-flux"
  acr_enabled               = "${var.acr_enabled}"
  gc_enabled                = "${var.gc_enabled}"
  create_helm_operator      = "${var.create_helm_operator}"
  create_helm_operator_crds = "${var.create_helm_operator_crds}"
  git_label                 = "${var.git_label}"
}

module "kubediff" {
  source = "../../common/kubediff"

  kubeconfig_complete = "${module.aks.kubeconfig_done}"
  gitops_ssh_url      = "${var.gitops_ssh_url}"
}

module "aks-dashboard" {
  source = "../../azure/aks-dashboard"

  kubeconfigadmin_filename = "${var.kubeconfigadmin_filename}"
  dashboard_cluster_role   = "${var.dashboard_cluster_role}"
  output_directory         = "${var.output_directory}"
  kubeconfigadmin_done     = "${module.aks.kubeconfigadmin_done}"
}

module "aks-role-assignment" {
  source = "../../azure/aks-rbac"

  kubeconfigadmin_filename = "${var.kubeconfigadmin_filename}"
  kubeconfigadmin_done     = "${module.aks.kubeconfigadmin_done}"
  output_directory         = "${var.output_directory}"
  owners                   = "${var.aks_owners}"
  contributors             = "${var.aks_contributors}"
  readers                  = "${var.aks_readers}"
}

module "kv-reader-identity" {
  source = "../../azure/key-vault-reader"

  kubeconfigadmin_filename = "${var.kubeconfigadmin_filename}"
  kubeconfigadmin_done     = "${module.aks.kubeconfigadmin_done}"
  output_directory         = "${var.output_directory}"

  resource_group_name             = "${var.resource_group_name}"
  location                        = "${var.resource_group_location}"
  aks_cluster_name                = "${var.cluster_name}"
  aks_cluster_resource_group_name = "${var.resource_group_name}"
  aks_cluster_location            = "${var.resource_group_location}"

  vault_name            = "${var.vault_name}"
  vault_reader_identity = "${var.vault_reader_identity}"
  aks_cluster_spn_name  = "${var.aks_cluster_spn_name}"
}
