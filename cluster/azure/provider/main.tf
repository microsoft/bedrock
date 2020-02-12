provider "azurerm" {
  version = ">=1.32.1"
}

# Needed for the traffic manager role assignment
provider "azuread" {
  version = ">=0.5.1"
}

# common modules
module "common-provider" {
  source = "../../common/provider"
}
