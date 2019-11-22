module "azure-provider" {
  source = "../provider"
}

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
}

data "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.log_analytics_name}"
  resource_group_name = "${var.log_analytics_resource_group_name}"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.cluster_name}"
  location            = "${var.aks_resource_group_location}"
  resource_group_name = "${var.aks_resource_group_name}"
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
      log_analytics_workspace_id = "${data.azurerm_log_analytics_workspace.workspace.id}"
    }

    http_application_routing {
      enabled = "${var.enable_http_application_routing}"
    }
  }
}
