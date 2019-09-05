module "azure-provider" {
  source = "../provider"
}

data "azurerm_client_config" "current" {}

resource "null_resource" "keyvault_reader" {
  count = "${var.vault_reader_identity != "" && var.vault_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done};KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} ${path.module}/ensure_vault_reader.sh -v ${var.vault_name} -n ${var.vault_reader_identity} -g ${var.resource_group_name} -a ${var.aks_cluster_resource_group_name} -c ${var.aks_cluster_name} -s \"${var.aks_cluster_spn_name}\" -l ${var.aks_cluster_location}"
  }

  triggers = {
    vault_reader_identity = "${var.vault_reader_identity}"
    vault_name            = "${var.vault_name}"
  }

}
