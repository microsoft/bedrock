module "azure-provider" {
  source = "../provider"
}

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.log_analytics_name}"
  location            = "${var.log_analytics_resource_group_location}"
  resource_group_name = "${var.log_analytics_resource_group_name}"
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "solution" {
  solution_name         = "ContainerInsights"
  location              = "${var.log_analytics_resource_group_location}"
  resource_group_name   = "${var.log_analytics_resource_group_name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.workspace.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.workspace.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}