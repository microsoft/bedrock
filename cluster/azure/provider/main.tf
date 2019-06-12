provider "azurerm" {
  version = "~>1.29.0"
}

# Needed for the traffic manager role assignment
provider "azuread" {
  version = "~>0.3.1"
}

# common modules
module "common-provider" {
  source = "../../common/provider"
}