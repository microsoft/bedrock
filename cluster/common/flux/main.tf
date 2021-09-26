module "common-provider" {
  source = "../provider"
}

resource "null_resource" "deploy_flux" {
  count = var.enable_flux ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfig_complete};KUBECONFIG=${var.output_directory}/${var.kubeconfig_filename} ${path.module}/deploy_flux.sh -b '${var.gitops_url_branch}' -f '${var.flux_repo_url}' -g '${var.gitops_ssh_url}' -k '${var.gitops_ssh_key_path}' -d '${var.flux_clone_dir}' -c '${var.gitops_poll_interval}' -l '${var.gitops_label}' -e '${var.gitops_path}' -s '${var.acr_enabled}' -r '${var.flux_image_repository}' -t '${var.flux_image_tag}' -z '${var.gc_enabled}'"
  }

  triggers = {
    enable_flux   = var.enable_flux
    flux_recreate = var.flux_recreate
    api_server_available = var.api_server_available
    flux_image_tag = var.flux_image_tag
  }
}
