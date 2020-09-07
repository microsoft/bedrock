data "azurerm_resource_group" "aksgitops" {
  name = var.resource_group_name
}

module "aks" {
  source = "../../azure/aks"

  resource_group_name                  = data.azurerm_resource_group.aksgitops.name
  cluster_name                         = var.cluster_name
  agent_vm_count                       = var.agent_vm_count
  agent_vm_size                        = var.agent_vm_size
  dns_prefix                           = var.dns_prefix
  vnet_subnet_id                       = var.vnet_subnet_id
  ssh_public_key                       = var.ssh_public_key
  msi_enabled                          = var.msi_enabled
  service_principal_id                 = var.service_principal_id
  service_principal_secret             = var.service_principal_secret
  service_cidr                         = var.service_cidr
  dns_ip                               = var.dns_ip
  docker_cidr                          = var.docker_cidr
  kubernetes_version                   = var.kubernetes_version
  kubeconfig_filename                  = var.kubeconfig_filename
  network_policy                       = var.network_policy
  network_plugin                       = var.network_plugin
  oms_agent_enabled                    = var.oms_agent_enabled
  kube_api_server_authorized_ip_ranges = var.kube_api_server_authorized_ip_ranges

  tags = var.tags
}

module "flux" {
  source = "../../common/flux"

  gitops_ssh_url       = var.gitops_ssh_url
  gitops_ssh_key_path  = var.gitops_ssh_key_path
  gitops_path          = var.gitops_path
  gitops_poll_interval = var.gitops_poll_interval
  gitops_label         = var.gitops_label
  gitops_url_branch    = var.gitops_url_branch
  enable_flux          = var.enable_flux
  flux_recreate        = var.flux_recreate
  kubeconfig_complete  = module.aks.kubeconfig_done
  kubeconfig_filename  = var.kubeconfig_filename
  flux_clone_dir       = "${var.cluster_name}-flux"
  acr_enabled          = var.acr_enabled
  gc_enabled           = var.gc_enabled
  api_server_available = module.api_server_access.api_server_open
}

module "kubediff" {
  source = "../../common/kubediff"

  kubeconfig_complete = module.aks.kubeconfig_done
  gitops_ssh_url      = var.gitops_ssh_url
}

module "api_server_access" {
  source = "../../azure/aks-api-server-access"

  resource_group_name = var.resource_group_name
  cluster_name = var.cluster_name
  kube_api_server_authorized_ip_ranges = var.kube_api_server_authorized_ip_ranges
  kube_api_server_temp_authorized_ip = var.kube_api_server_temp_authorized_ip
  kubeconfig_complete = module.aks.kubeconfig_done
  flux_done = module.flux.flux_done
  kubediff_done = module.kubediff.kubediff_done
}
