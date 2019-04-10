output "kubeconfig_done" {
  value = "${module.aks.kubeconfig_done}"
}

output "cluster_derived_resource_group" {
  value = "MC_${var.resource_group_name}_${var.cluster_name}_${var.resource_group_location}"
}