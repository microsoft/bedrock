module "azure-provider" {
  source = "../provider"
}

resource "null_resource" "aks_roleassignment" {
  count = "${var.enable_kubediff ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done};KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} ${path.module}/apply_aad_rbac.sh -o ${var.owners}  -c ${var.contributors} -r ${var.readers}"
  }

  triggers = {
    owners       = "${var.owners}"
    contributors = "${var.contributors}"
    readers      = "${var.readers}"
  }
}
