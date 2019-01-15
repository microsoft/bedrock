resource "azurerm_resource_group" "cluster" {
  name     = "${var.cluster_name}-rg"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "cluster" {
  name                = "${var.cluster_name}-vnet"
  address_space       = ["${var.vnet_address_space}"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cluster.name}"
}

resource "azurerm_subnet" "cluster" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = "${azurerm_resource_group.cluster.name}"
  address_prefix       = "${var.subnet_address_space}"
  virtual_network_name = "${azurerm_virtual_network.cluster.name}"
}

/*

NOTE:  Currently you can not enable RBAC without a backing AAD service principal.  In the meantime, use the az command line.
TODO:  This support is expected within a couple of releases -- switch back when its available.

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.cluster.location}"
  resource_group_name = "${azurerm_resource_group.cluster.name}"
  dns_prefix          = "${var.cluster_name}"
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
    vnet_subnet_id  = "${azurerm_subnet.cluster.id}"
  }

  network_profile {
    network_plugin = "azure"
  }

  role_based_access_control {
    azure_active_directory {
      server_app_id     = "${var.aad_server_app_id}"
      server_app_secret = "${var.aad_server_app_secret}"
      client_app_id     = "${var.aad_client_app_id}"
      tenant_id         = "${var.aad_tenant_id}"
    }
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }
}

*/

resource "null_resource" "create_cluster" {
  provisioner "local-exec" {
    command = "az aks create -g ${azurerm_resource_group.cluster.name} -n ${var.cluster_name} -l ${azurerm_resource_group.cluster.location} --kubernetes-version ${var.kubernetes_version} --node-count ${var.agent_vm_count} --node-vm-size ${var.agent_vm_size} --network-plugin azure --vnet-subnet-id ${azurerm_subnet.cluster.id}"
  }

  depends_on = ["azurerm_subnet.cluster"]
}

resource "null_resource" "cluster_credentials" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.cluster.name} --name ${var.cluster_name} --overwrite-existing"
  }

  //depends_on = ["azurerm_kubernetes_cluster.cluster"]
  depends_on = ["null_resource.create_cluster"]
}

resource "null_resource" "deploy_flux" {
  provisioner "local-exec" {
    command = "./deploy-flux.sh -f ${var.flux_repo_url} -g ${var.gitops_url} -k ${var.gitops_ssh_key}"
  }

  depends_on = ["null_resource.cluster_credentials"]
}
