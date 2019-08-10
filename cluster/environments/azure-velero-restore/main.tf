/*terraform {
  backend "azurerm" {}
}*/

data "azurerm_client_config" "current" {}

module "common-provider" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/common/provider"
}

resource "azurerm_resource_group" "cluster_rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "null_resource" "cloud_credentials" {
  provisioner "local-exec" {
    command = "echo \"AZURE_SUBSCRIPTION_ID=${var.subscription_id}\nAZURE_TENANT_ID=${var.tenant_id}\nAZURE_CLIENT_ID=${var.service_principal_id}\nAZURE_CLIENT_SECRET=${var.service_principal_secret}\nAZURE_RESOURCE_GROUP=MC_${azurerm_resource_group.cluster_rg.name}_${var.cluster_name}_${var.resource_group_location}\" > ./credentials-velero"
  }
}

module "aks" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/azure/aks"

  agent_vm_count           = "${var.agent_vm_count}"
  agent_vm_size            = "${var.agent_vm_size}"
  cluster_name             = "${var.cluster_name}"
  dns_prefix               = "${var.dns_prefix}"
  resource_group_location  = "${var.resource_group_location}"
  resource_group_name      = "${azurerm_resource_group.cluster_rg.name}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  ssh_public_key           = "${var.ssh_public_key}"
  vnet_subnet_id           = "${var.vnet_subnet_id}"
  output_directory         = "${var.output_directory}"
  kubeconfig_filename      = "${var.kubeconfig_filename}"
}

# Deploy keyvault flexvolume
module "flex_volume" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/azure/keyvault_flexvol"

  resource_group_name      = "${var.keyvault_resource_group}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  tenant_id                = "${data.azurerm_client_config.current.tenant_id}"
  keyvault_name            = "${var.keyvault_name}"

  kubeconfig_complete = "${module.aks.kubeconfig_done}"
}

module "velero" {
  source = "github.com/microsoft/bedrock?ref=bedrock.msi//cluster/common/velero"

  velero_bucket                          = "${var.velero_bucket}"
  velero_backup_location_config          = "${var.velero_backup_location_config}"
  velero_volume_snapshot_location_config = "${var.velero_volume_snapshot_location_config}"
  velero_backup_name                     = "${var.velero_backup_name}"
  velero_delete_pod                      = "${var.velero_delete_pod}"
  velero_uninstall                       = "${var.velero_uninstall}"

  kubeconfig_complete = "${module.aks.kubeconfig_done}"
}
