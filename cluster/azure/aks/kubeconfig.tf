resource "null_resource" "cluster_credentials" {
  count  = "${var.enable_cluster_creds_to_disk ? 1 : 0}"

  provisioner "local-exec" {
    command = "if [ ! -e ${var.output_directory} ]; then mkdir -p ${var.output_directory}; fi && echo \"${azurerm_kubernetes_cluster.cluster.kube_config}\" > ${var.output_directory}/kube_config"
  }

  triggers {
    enable_cluster_creds_to_disk = "${var.enable_cluster_creds_to_disk}"
  }

  depends_on = ["azurerm_kubernetes_cluster.cluster"]

}