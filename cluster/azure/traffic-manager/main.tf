module "azure-provider" {
  source = "../provider"
}

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
}

resource "null_resource" "traffic_manager" {
  count = "${var.traffic_manager_name != "" && var.resource_group_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/create_traffic_manager.sh -s ${var.subscription_id} -g ${var.resource_group_name} -t ${var.traffic_manager_name} -e \"${var.service_names}\" -u \"${var.service_suffix}\" -z \"${var.dns_zone_name}\" -p \"${var.probe_path}\""
  }

  triggers = {
    traffic_manager_name = "${var.traffic_manager_name}"
    subscription_id      = "${var.subscription_id}"
    resource_group_name  = "${var.resource_group_name}"
    service_names        = "${var.service_names}"
    service_suffix       = "${var.service_suffix}"
    dns_zone_name        = "${var.dns_zone_name}"
    probe_path           = "${var.probe_path}"
  }
}
