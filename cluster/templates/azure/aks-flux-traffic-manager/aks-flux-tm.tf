# Create the first AKS cluster
module "aks-flux-01" "cluster01" {
  source = "../aks-flux"

  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  cluster_name            = "${var.cluster01_name}"
  cluster_location        = "${var.cluster01_location}"
  dns_prefix              = "${var.dns01_prefix}"
  vnet_address_space      = "${var.vnet_address_space}"
  subnet_address_space    = "${var.subnet_address_space}"
  agent_vm_count          = "${var.agent_vm_count}"
  agent_vm_size           = "${var.agent_vm_size}"
  admin_user              = "${var.admin_user}"
  ssh_public_key          = "${var.ssh_public_key}"
  client_id               = "${var.client_id}"
  client_secret           = "${var.client_secret}"
  kubernetes_version      = "${var.kubernetes_version}"
  gitops_url              = "${var.gitops_url}"
  gitops_ssh_key          = "${var.gitops_ssh_key}"
  output_directory        = "${var.output_directory}"
}

# Create the second AKS cluster
module "aks-flux-02" "cluster02" {
  source = "../aks-flux"

  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  cluster_name            = "${var.cluster02_name}"
  cluster_location        = "${var.cluster02_location}"
  dns_prefix              = "${var.dns02_prefix}"
  vnet_address_space      = "${var.vnet_address_space}"
  subnet_address_space    = "${var.subnet_address_space}"
  agent_vm_count          = "${var.agent_vm_count}"
  agent_vm_size           = "${var.agent_vm_size}"
  admin_user              = "${var.admin_user}"
  ssh_public_key          = "${var.ssh_public_key}"
  client_id               = "${var.client_id}"
  client_secret           = "${var.client_secret}"
  kubernetes_version      = "${var.kubernetes_version}"
  gitops_url              = "${var.gitops_url}"
  gitops_ssh_key          = "${var.gitops_ssh_key}"
  output_directory        = "${var.output_directory}"
}

# Read AKS cluster service principal (client) object to create a role assignment
data "azuread_service_principal" "sp" {
  application_id = "${var.client_id}"
}

# Create a role assignment with Contributor role for AKS client service principal object to join vnet/subnet/ip for load balancer/ingress controller
resource "azurerm_role_assignment" "aks01ra" {
  principal_id         = "${data.azuread_service_principal.sp.id}"
  role_definition_name = "${var.aks_client_role_assignment_role}"
  scope                = "${module.aks-flux-01.aks_cluster_resource_group_id}"
}

# Create a static public ip that will be used in Traffic Manager Endpoint
resource "azurerm_public_ip" "pip01" {
  name                = "${module.aks-flux-01.aks_cluster_name}-ip"
  location            = "${var.cluster01_location}"
  resource_group_name = "${module.aks-flux-01.aks_cluster_resource_group_name}"
  allocation_method   = "${var.ip_allocation_method}"
  domain_name_label   = "${var.dns01_prefix}pip"
}

# Create a static public ip that will be used in Traffic Manager Endpoint
resource "azurerm_public_ip" "pip02" {
  name                = "${module.aks-flux-02.aks_cluster_name}-ip"
  location            = "${var.cluster02_location}"
  resource_group_name = "${module.aks-flux-02.aks_cluster_resource_group_name}"
  allocation_method   = "${var.ip_allocation_method}"
  domain_name_label   = "${var.dns02_prefix}pip"
}

# Create the resource group for Traffic Manager
resource "azurerm_resource_group" "globalrg" {
  name     = "${var.global_resource_group_name}"
  location = "${var.global_resource_group_location}"
}

# Create the Azure Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "profile" {
  name                   = "${azurerm_resource_group.globalrg.name}-tmprofile"
  resource_group_name    = "${azurerm_resource_group.globalrg.name}"
  traffic_routing_method = "${var.traffic_manager_routing_method}"

  dns_config {
    relative_name = "${azurerm_resource_group.globalrg.name}"
    ttl           = 30
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }

  depends_on = ["azurerm_public_ip.pip01", "azurerm_public_ip.pip02"]
}

# Create the Azure Traffic Manager Profile Endpoint with public IP 1 above
resource "azurerm_traffic_manager_endpoint" "endpoint01" {
  name                = "endpoint1"
  resource_group_name = "${azurerm_resource_group.globalrg.name}"
  profile_name        = "${azurerm_traffic_manager_profile.profile.name}"
  target              = "${var.dns01_prefix}-ep01"
  target_resource_id  = "${azurerm_public_ip.pip01.id}"
  type                = "${var.traffic_manager_endpoint_type}"
  depends_on          = ["azurerm_traffic_manager_profile.profile"]
}

# Create the Azure Traffic Manager Profile Endpoint with public IP 2 above
resource "azurerm_traffic_manager_endpoint" "endpoint02" {
  name                = "endpoint2"
  resource_group_name = "${azurerm_resource_group.globalrg.name}"
  profile_name        = "${azurerm_traffic_manager_profile.profile.name}"
  target              = "${var.dns02_prefix}-ep02"
  target_resource_id  = "${azurerm_public_ip.pip02.id}"
  type                = "${var.traffic_manager_endpoint_type}"
  depends_on          = ["azurerm_traffic_manager_profile.profile"]
}
