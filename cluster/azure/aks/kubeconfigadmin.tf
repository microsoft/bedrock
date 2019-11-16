resource "null_resource" "cluster_credentials_admin" {
  count = "${var.kubeconfig_to_disk ? 1 : 0}"

  provisioner "local-exec" {
    command = "if [ ! -e ${var.output_directory} ]; then mkdir -p ${var.output_directory}; fi && kubeconfig=\"${azurerm_kubernetes_cluster.cluster.kube_admin_config_raw}\" kubeconfigfile=\"${var.output_directory}/${var.kubeconfigadmin_filename}\" ${path.module}/write_kubeconfig.ps1"
  }

  triggers = {
    kubeconfig_to_disk  = "${var.kubeconfig_to_disk}"
    kubeconfig_recreate = "${var.kubeconfig_recreate}"
  }

  depends_on = ["azurerm_kubernetes_cluster.cluster"]
}
