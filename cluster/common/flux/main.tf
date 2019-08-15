module "common-provider" {
  source = "../provider"
}

resource "null_resource" "deploy_flux" {
  count = "${var.enable_flux ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done};KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} ${path.module}/deploy_flux.sh -b '${var.gitops_url_branch}' -f '${var.flux_repo_url}' -g '${var.gitops_ssh_url}' -k '${var.gitops_ssh_key}' -d '${var.flux_clone_dir}' -c '${var.gitops_poll_interval}' -e '${var.gitops_path}' -s '${var.acr_enabled}' -r '${var.flux_image_repository}' -t '${var.flux_image_tag}' -z '${var.gc_enabled}'"
  }

  triggers = {
    enable_flux   = "${var.enable_flux}"
    flux_recreate = "${var.flux_recreate}"
  }
}
