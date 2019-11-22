module "common-provider" {
  source = "../../common/provider"
}

resource "null_resource" "deploy_flexvol" {
  count = "${var.env_name != "" && var.flexvol_version != "" && var.flexvol_namespace != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = <<-EOT
      echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfig_complete}; \
      KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} \
      pwsh ${path.module}/deploy_flexvol.ps1 \
      -SubscriptionId ${var.aks_subscription_id} \
      -EnvName ${var.env_name} \
      -ModuleFolder ${path.module} \
      -FlexVolVersion ${var.flexvol_version} \
      -FlexVolNamespace ${var.flexvol_namespace}
    EOT
  }

  triggers = {
    aks_subscription_id = "${var.aks_subscription_id}"
    env_name            = "${var.env_name}"
    flexvol_version     = "${var.flexvol_version}"
    flexvol_namespace   = "${var.flexvol_namespace}"
  }
}
