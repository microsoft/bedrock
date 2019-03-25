output "kubeconfig_done" {
  value = "${module.aks.kubeconfig_done}"
}

output "vnet_id" {
  value = "${module.vnet.vnet_id}"
}

output "vnet_name" {
  value = "${module.vnet.vnet_name}"
}
