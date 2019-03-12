provider "null" {
    version = "~>2.0.0"
}

resource "null_resource" "deploy_flexvol" {
  count  = "${var.enable_flexvol ? 1 : 0}"
  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfig_complete};KUBECONFIG=${var.output_directory}/${var.kubeconfig_filename} ${path.module}/deploy_flexvol.sh -i ${var.service_principal_id} -p ${var.service_principal_secret} -s ${var.subscription_id} -r ${var.resource_group_name} -k ${var.keyvault_name}"
  }

  triggers {
    enable_flexvol  = "${var.enable_flexvol}"
    flexvol_recreate = "${var.flexvol_recreate}"
  }
}
