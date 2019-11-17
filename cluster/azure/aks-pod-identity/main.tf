resource "null_resource" "pod_identity" {
  count = "${var.env_name != "" && var.pod_identity_version != "" && var.pod_identity_namespace != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = <<-EOT
      echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done}; \
      KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} \
      pwsh ${path.module}/deploy_pod_identity.ps1 \
      -EnvName ${var.env_name} \
      -ModuleFolder \"${path.module}\" \
      -PodIdentityVersion ${var.pod_identity_version} \
      -PodIdentityNamespace ${var.pod_identity_namespace}
    EOT
  }

  triggers = {
    env_name               = "${var.env_name}"
    pod_identity_version   = "${var.pod_identity_version}"
    pod_identity_namespace = "${var.pod_identity_namespace}"
  }
}
