# Create and configure MSI for keyvault
module "pod_identity" {
    source = "../../azure/pod_identity_msi"
    resource_group_name         = "${azurerm_resource_group.global_rg.name}"
    service_principal_object_id = "${var.service_principal_object_id}"
    identity_name               = "${var.identity_name}"
}
