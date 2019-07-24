module "azure-provider" {
  source = "../provider"
}

module "common-provider" {
  source = "../../common/provider"
}

data "azurerm_resource_group" "podid" {
  name = "${var.resource_group_name}"
}

data "azurerm_user_assigned_identity" "podid" {
  name                = "${var.identity_name}"
  resource_group_name = "${data.azurerm_resource_group.podid.name}"
}

resource "null_resource" "deploy_pod_identity" {
  count = "${var.enable_pod_identity ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfig_complete};KUBECONFIG=${var.output_directory}/${var.kubeconfig_filename} ${path.module}/deploy_pod_identity.sh -u '${var.pod_identity_install_url}'"
  }

  triggers = {
    enable_pod_identity   = "${var.enable_pod_identity}"
    pod_identity_recreate = "${var.pod_identity_recreate}"
  }
}

resource "null_resource" "install_azure_identity" {
  count = "${var.enable_pod_identity ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfig_complete};KUBECONFIG=${var.output_directory}/${var.kubeconfig_filename} ${path.module}/install_azure_identity.sh -g '${data.azurerm_resource_group.podid.name}' -s '${var.subscription_id}' -c '${data.azurerm_user_assigned_identity.podid.client_id}' -i'${var.identity_name}'"
  }

  depends_on = ["null_resource.deploy_pod_identity"]

  triggers = {
    enable_pod_identity   = "${var.enable_pod_identity}"
    pod_identity_recreate = "${var.pod_identity_recreate}"
    pod_identity_deployed = "${null_resource.deploy_pod_identity.id}"
  }
}
