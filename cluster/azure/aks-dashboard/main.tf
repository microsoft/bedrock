resource "null_resource" "dashboard_access" {
  count = "${var.dashboard_cluster_role != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done};KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} ${path.module}/apply_dashboard_rbac.sh -r ${var.dashboard_cluster_role} -a {path.module}/dashboard_admin_rbac.yaml -u {path.module}/dashboard_rbac.yaml"
  }
}
