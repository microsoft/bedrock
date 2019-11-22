resource "null_resource" "enable_azure_monitoring" {
  count = "${var.enable_azure_monitoring ? 1 : 0}"

  provisioner "local-exec" {
    command = "pwsh ${path.module}/enable_aks_monitoring.ps1 -ResourceGroupName ${var.aks_resource_group_name} -ClusterName ${var.cluster_name}"
  }

  triggers = {
    enable_azure_monitoring  = "${var.enable_azure_monitoring}"
  }

  depends_on = ["azurerm_kubernetes_cluster.cluster"]
}