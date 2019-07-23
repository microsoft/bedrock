module "provider" {
  #source = "github.com/Microsoft/bedrock/cluster/azure/provider"
  source = "../../azure/provider"
}

data "azurerm_client_config" "current" {}
