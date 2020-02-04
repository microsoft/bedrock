module "provider" {
  #source = "github.com/microsoft/bedrock?ref=master//cluster/azure/provider"
  source = "../../azure/provider"
}

# Read AKS cluster service principal (client) object to create a role assignment
data "azuread_service_principal" "sp" {
  application_id = var.service_principal_id
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "keyvault" {
  name     = var.keyvault_resource_group
}

# Create Azure Key Vault role for SP
module "keyvault_flexvolume_role" {
  #source = "github.com/microsoft/bedrock?ref=master//cluster/azure/keyvault_flexvol_role"
  source = "../../azure/keyvault_flexvol_role"

  resource_group_name  = var.keyvault_resource_group
  service_principal_id = var.service_principal_id
  subscription_id      = data.azurerm_client_config.current.subscription_id
  keyvault_name        = var.keyvault_name
}
