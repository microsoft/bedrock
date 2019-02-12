resource "null_resource" "cluster_credentials" {
  count  = "${var.kubeconfig_to_disk ? 1 : 0}"

  provisioner "local-exec" {
    command = "if [ ! -e ${var.output_directory} ]; then mkdir -p ${var.output_directory}; fi && echo ${jsonencode(azurerm_kubernetes_cluster.cluster.kube_config_raw)} > ${var.output_directory}/${var.kubeconfig_filename}"
  }

  triggers {
    kubeconfig_to_disk  = "${var.kubeconfig_to_disk}"
    kubeconfig_recreate = "${var.kubeconfig_recreate}"
  }

  depends_on = ["azurerm_kubernetes_cluster.cluster"]

}