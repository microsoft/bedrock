resource "null_resource" "enable_azure_monitoring" {
  count = "${var.enable_azure_monitoring ? 1 : 0}"

  provisioner "local-exec" {
    command = "az aks disable-addons --resource-group ${var.resource_group_name} --name ${var.cluster_name} --addons monitoring; az aks enable-addons --resource-group ${var.resource_group_name} --name ${var.cluster_name} --addons monitoring"
  }

  triggers = {
    enable_azure_monitoring  = "${var.enable_azure_monitoring}"
  }

  depends_on = ["azurerm_kubernetes_cluster.cluster"]
}