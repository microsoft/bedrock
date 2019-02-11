module "provider" {
    source = "../../azure/provider"
}

/**
 * Uncomment to enable remote storage of Terraform state (terraform.tfstate)
 * file to Azure Blob Store.
 * 
 * The following additional variables must be defined:
 *
 *  - tfstate_storage_account_name -- name of the storage account to store the state to
 *  - tfstate_container_name -- name of the container to store the state in
 *  - tfstate_storage_account_key -- key for accessing 
terraform {
   backend "azure" {
       storage_account_name = "${var.tfstate_storage_account_name}"
       container_name = "${var.tfstate_container_name}"
       key = "${var.tfstate_storage_account_key}"
   }
}
*/

# terraform {
#    backend "azurerm" {
#    }
# }

resource "azurerm_resource_group" "clusterrg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "azurerm_resource_group" "vnetrg" {
  name     = "aksvnetrg"
  location = "${var.resource_group_location}"
}

module "vnet" {
    source = "../../azure/vnet"

    resource_group_name = "${azurerm_resource_group.vnetrg.name}"
    location            = "${azurerm_resource_group.vnetrg.location}"
    subnet_names        = ["${var.cluster_name}-aks-subnet"]

    tags = {
      environment = "azure-simple"
    }

}

module "aks" {
    source = "../../azure/aks"

    resource_group_name       = "${azurerm_resource_group.clusterrg.name}"
    cluster_name              = "${var.cluster_name}"
    cluster_location          = "${azurerm_resource_group.clusterrg.location}"
    dns_prefix                = "${var.dns_prefix}"
    vnet_subnet_id            = "${module.vnet.vnet_subnet_ids}"
    ssh_public_key            = "${var.ssh_public_key}"
    service_principal_id      = "${var.service_principal_id}"
    service_principal_secret  = "${var.service_principal_secret}"

}

module "aks-flux" {
    source = "../../common/flux"

    gitops_url                = "${var.gitops_url}"
    gitops_ssh_key            = "${var.gitops_ssh_key}"
}
