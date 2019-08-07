resource "null_resource" "dashboard_access" {
  count = "${var.dashboard_cluster_role != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done};KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} if [ ${var.dashboard_cluster_role} = 'cluster_admin' ]; then kubectl apply -f ${path.module}/dashboard_admin_rbac.yaml else kubectl apply -f ${path.module}/dashboard_rbac.yaml fi"
  }
}
