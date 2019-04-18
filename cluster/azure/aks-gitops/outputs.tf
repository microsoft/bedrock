output "kubeconfig_done" {
  value = "${module.aks.kubeconfig_done}"
}

output "cluster_derived_resource_group" {
  value = "${module.aks.cluster_derived_resource_group}"
}