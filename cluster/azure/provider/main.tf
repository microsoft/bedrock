provider "azurerm" {
  version = "=2.5.0"
  features {}
}

# Needed for the traffic manager role assignment
provider "azuread" {
  version = "~>0.7.0"
}

# common modules
module "common-provider" {
  source = "../../common/provider"
}
