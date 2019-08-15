module "azure-provider" {
  source = "../provider"
}

resource "azurerm_resource_group" "cluster" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "random_id" "workspace" {
  keepers = {
    group_name = "${azurerm_resource_group.cluster.name}"
  }

  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "bedrock-k8s-workspace-${random_id.workspace.hex}"
  location            = "${azurerm_resource_group.cluster.location}"
  resource_group_name = "${azurerm_resource_group.cluster.name}"
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "solution" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_resource_group.cluster.location}"
  resource_group_name   = "${azurerm_resource_group.cluster.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.workspace.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.workspace.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.cluster.location}"
  resource_group_name = "${azurerm_resource_group.cluster.name}"
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
    vnet_subnet_id  = "${var.vnet_subnet_id}"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "${var.network_policy}"
    service_cidr       = "${var.service_cidr}"
    dns_service_ip     = "${var.dns_ip}"
    docker_bridge_cidr = "${var.docker_cidr}"
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      server_app_id     = "${var.server_app_id}"
      server_app_secret = "${var.server_app_secret}"
      client_app_id     = "${var.client_app_id}"
    }
  }

  service_principal {
    client_id     = "${var.service_principal_id}"
    client_secret = "${var.service_principal_secret}"
  }

  addon_profile {
    oms_agent {
      enabled                    = "${var.oms_agent_enabled}"
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.workspace.id}"
    }

    http_application_routing {
      enabled = "${var.enable_http_application_routing}"
    }
  }
}
