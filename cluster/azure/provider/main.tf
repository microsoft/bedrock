provider "azurerm" {
    version = "~>1.28.0"
}

provider "null" {
}

terraform {
  required_version = "~> 0.12.6"
}

# Needed for the traffic manager role assignment
provider "azuread" {
  version = "~>0.3.0"
}
