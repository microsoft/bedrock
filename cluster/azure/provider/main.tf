provider "azurerm" {
    version = "=1.21.0"
}

provider "null" {
    version = "~>2.0.0"
}

terraform {
  required_version = "~> 0.11.11"
}
