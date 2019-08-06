output "kubeconfig_done" {
  value = "${module.aks.kubeconfig_done}"
}

output "aks_flux_kubediff_done" {
  value = "${module.aks.kubeconfig_done}_${module.flux.flux_done}_${module.kubediff.kubediff_done}"
}
