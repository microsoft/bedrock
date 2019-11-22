module "azure-provider" {
  source = "../provider"
}

provider "azurerm" {
  subscription_id = "${var.aks_subscription_id}"
}

resource "null_resource" "create_k8s_configmap" {
  count = "${var.k8s_configmap_name != "" && var.key_vault_name != "" && var.key_vault_secret_names != "" && var.k8s_configmap_keys != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done};KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} ${path.module}/install-kube-configmap.sh -a ${var.aks_subscription_id} -b ${var.vault_subscription_id} -n ${var.k8s_namespace} -c ${var.k8s_configmap_name} -k \"${var.k8s_configmap_keys}\" -v ${var.key_vault_name} -s \"${var.key_vault_secret_names}\""
  }

  triggers = {
    aks_subscription_id      = "${var.aks_subscription_id}"
    k8s_namespace            = "${var.k8s_namespace}"
    k8s_configmap_name       = "${var.k8s_configmap_name}"
    k8s_configmap_keys       = "${var.k8s_configmap_keys}"
    vault_subscription_id    = "${var.vault_subscription_id}"
    key_vault_name           = "${var.key_vault_name}"
    key_vault_secret_names   = "${var.key_vault_secret_names}"
    key_vault_secret_version = "${var.key_vault_secret_version}"
  }
}
