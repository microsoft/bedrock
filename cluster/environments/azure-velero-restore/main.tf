/*terraform {
  backend "azurerm" {}
}*/

data "azurerm_client_config" "current" {}

module "common-provider" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/common/provider"
}

data "azurerm_resource_group" "cluster_rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

data "azurerm_resource_group" "keyvault" {
  name     = "${var.keyvault_resource_group}"
}

resource "null_resource" "cloud_credentials" {
  provisioner "local-exec" {
    command = "echo \"AZURE_SUBSCRIPTION_ID=${var.subscription_id}\nAZURE_TENANT_ID=${var.tenant_id}\nAZURE_CLIENT_ID=${var.service_principal_id}\nAZURE_CLIENT_SECRET=${var.service_principal_secret}\nAZURE_RESOURCE_GROUP=MC_${data.azurerm_resource_group.cluster_rg.name}_${var.cluster_name}_${var.resource_group_location}\" > ./credentials-velero"
  }
}

module "aks" {
  #source = "github.com/microsoft/bedrock?ref=master//cluster/azure/aks"
  source = "../../cluster/azure/aks"

  agent_vm_count           = "${var.agent_vm_count}"
  agent_vm_size            = "${var.agent_vm_size}"
  cluster_name             = "${var.cluster_name}"
  dns_prefix               = "${var.dns_prefix}"
  resource_group_name      = "${data.azurerm_resource_group.cluster_rg.name}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  ssh_public_key           = "${var.ssh_public_key}"
  vnet_subnet_id           = "${var.vnet_subnet_id}"
  output_directory         = "${var.output_directory}"
  kubeconfig_filename      = "${var.kubeconfig_filename}"
}

# Create Azure Key Vault role for SP
module "keyvault_flexvolume_role" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/keyvault_flexvol_role"

  resource_group_name  = "${data.azurerm_resource_group.keyvault.name}"
  service_principal_id = "${var.service_principal_id}"
  subscription_id      = "${data.azurerm_client_config.current.subscription_id}"
  keyvault_name        = "${var.keyvault_name}"
}

# Deploy central keyvault flexvolume
module "flex_volume" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/keyvault_flexvol"

  resource_group_name      = "${data.azurerm_resource_group.keyvault.name}"
  service_principal_id     = "${var.service_principal_id}"
  service_principal_secret = "${var.service_principal_secret}"
  tenant_id                = "${data.azurerm_client_config.current.tenant_id}"
  keyvault_name            = "${var.keyvault_name}"

  kubeconfig_complete = "${module.aks.kubeconfig_done}"
}

module "velero" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/common/velero"

  velero_bucket                          = "${var.velero_bucket}"
  velero_backup_location_config          = "${var.velero_backup_location_config}"
  velero_volume_snapshot_location_config = "${var.velero_volume_snapshot_location_config}"
  velero_backup_name                     = "${var.velero_backup_name}"
  velero_delete_pod                      = "${var.velero_delete_pod}"
  velero_uninstall                       = "${var.velero_uninstall}"

  kubeconfig_complete = "${module.aks.kubeconfig_done}"
}
