output "kubeconfig_done" {
  value = module.aks.kubeconfig_done
}

output "aks_flux_kubediff_done" {
  value = "${module.aks.kubeconfig_done}_${module.flux.flux_done}_${module.kubediff.kubediff_done}"
}

output "aks_resource_id" {
  value = module.aks.resource_id
}

output "node_resource_group" {
  value = module.aks.node_resource_group
}

output "kubelet_identity" {
  value = module.aks.kubelet_identity
}

output "system_identity" {
  value = module.aks.system_identity
}

output "oms_agent_identity" {
  value = module.aks.oms_agent_identity
}
