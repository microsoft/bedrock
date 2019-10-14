module "azure-provider" {
  source = "../provider"
}

resource "null_resource" "recycle_k8s_pods" {
  count = "${var.k8s_namespace != ""? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done};KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} ${path.module}/recycle_k8s_pods.sh -n ${var.k8s_namespace}"
  }

}
