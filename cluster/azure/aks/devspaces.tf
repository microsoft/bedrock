resource "null_resource" "enable_dev_spaces" {
  count = "${var.enable_dev_spaces ? 1 : 0}"

  provisioner "local-exec" {
    command = "az aks use-dev-spaces --resource-group ${var.resource_group_name} --name ${var.cluster_name} --space ${var.space_name} --yes"
  }

  triggers = {
    enable_dev_spaces  = "${var.enable_dev_spaces}"
  }

  depends_on = ["azurerm_kubernetes_cluster.cluster"]
}
