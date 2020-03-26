module "acr" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/acr"

  acr_name                 = var.acr_name
  enable_acr               = var.enable_acr
  resource_group_name      = data.azurerm_resource_group.cluster_rg.name
}
