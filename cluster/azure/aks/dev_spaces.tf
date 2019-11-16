resource "null_resource" "enable_dev_spaces" {
  count = "${var.enable_dev_spaces ? 1 : 0}"

  provisioner "local-exec" {
    command = "az aks use-dev-spaces --resource-group ${var.aks_resource_group_name} --name ${var.cluster_name} --space ${var.dev_space_name} --yes"
  }

  triggers = {
    enable_dev_spaces = "${var.enable_dev_spaces}"
    dev_space_name    = "${var.dev_space_name}"
  }

  depends_on = ["azurerm_kubernetes_cluster.cluster"]
}
