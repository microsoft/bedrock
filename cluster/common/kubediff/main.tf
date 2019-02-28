provider "null" {
    version = "~>2.0.0"
}
 
resource "null_resource" "deploy_kubediff" {
  count  = "${var.enable_kubediff ? 1 : 0}"
  provisioner "local-exec" {
       command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfig_complete};KUBECONFIG=${var.output_directory}/${var.kubeconfig_filename} ${path.module}/deploy_kubediff.sh -f ${var.kubediff_repo_url}  -g ${var.gitops_ssh_url} "
  }
 
  triggers {
    enable_kubediff  = "${var.enable_kubediff}"
  }
 
}