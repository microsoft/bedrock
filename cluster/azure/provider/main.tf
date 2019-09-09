provider "azurerm" {
  version = "~>1.33.1"
}

# Needed for the traffic manager role assignment
provider "azuread" {
  version = "~>0.6.0"
}

# common modules
module "common-provider" {
  source = "../../common/provider"
}
