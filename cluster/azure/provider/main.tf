provider "azurerm" {
    version = "~>1.25.0"
    subscription_id = "74ebc5bb-c3da-48e3-b3e9-db8baf3ca4a1"
    client_id       = "f8ec33d6-dd15-45ef-a8f0-fb9d25c8f835"
    client_secret   = "7400863e-bb45-4c86-a7db-e0528102c3c9"
    tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd011db47"
}



provider "null" {
  version = "~>2.0.0"
}

terraform {
  required_version = "~> 0.11.13"
}

# Needed for the traffic manager role assignment
provider "azuread" {
  version = "~>0.1"
}
