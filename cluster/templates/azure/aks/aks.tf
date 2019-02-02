resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.cluster_name}-vnet"
  address_space       = ["${var.vnet_address_space}"]
  location            = "${var.cluster_location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_address_space}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.cluster_name}"
  location            = "${var.cluster_location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  dns_prefix          = "${var.dns_prefix}"
  kubernetes_version  = "${var.kubernetes_version}"

  linux_profile {
    admin_username = "${var.admin_user}"

    ssh_key {
      key_data = "${var.ssh_public_key}"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_vm_count}"
    vm_size         = "${var.agent_vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id  = "${azurerm_subnet.subnet.id}"
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control {
    enabled = true
  /*
    azure_active_directory {
      server_app_id     = "${var.aad_server_app_id}"
      server_app_secret = "${var.aad_server_app_secret}"
      client_app_id     = "${var.aad_client_app_id}"
      tenant_id         = "${var.aad_tenant_id}"
    }
  */
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }
}
