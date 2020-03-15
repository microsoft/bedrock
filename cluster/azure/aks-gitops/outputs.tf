output "kubeconfig_done" {
  value = module.aks.kubeconfig_done
}

output "aks_flux_kubediff_done" {
  value = "${module.aks.kubeconfig_done}_${module.flux.flux_done}_${module.kubediff.kubediff_done}"
}

output "aks_resource_id" {
  value = module.aks.resource_id
}

output "msi_client_id" {
  value = module.aks.msi_client_id
}

output "kubelet_client_id" {
  value = module.aks.kubelet_client_id
}

output "kubelet_id" {
  value = module.aks.kubelet_id
}

output "aks_user_identity_id" {
  value = module.aks.aks_user_identity_id
}

output "aks_user_identity_principal_id" {
  value = module.aks.aks_user_identity_principal_id
}

output "aks_user_identity_client_id" {
  value = module.aks.aks_user_identity_client_id
}