# provider "azurerm" {
#   version = "~>1.40.0"
# }

provider "azuread" {
  version = "~>0.7.0"
}

# common modules
module "common-provider" {
  source = "../../common/provider"
}
