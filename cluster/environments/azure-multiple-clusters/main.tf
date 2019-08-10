module "provider" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/azure/provider"
}

data "azurerm_client_config" "current" {}