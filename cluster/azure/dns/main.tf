module "azure-provider" {
  source = "../provider"
}

resource "null_resource" "dnszone" {
  count = "${var.name != "" && var.resource_group_name != "" && var.service_principal_object_id != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/ensure_dns_zone.sh -s ${var.dns_subscription_id} -g ${var.resource_group_name} -z ${var.name} -c ${var.caa_issuer} -o ${var.service_principal_object_id} -e ${var.env_name}"
  }

  triggers = {
    name                        = "${var.name}"
    dns_subscription_id         = "${var.dns_subscription_id}"
    resource_group_name         = "${var.resource_group_name}"
    service_principal_object_id = "${var.service_principal_object_id}"
    caa_issuer                  = "${var.caa_issuer}"
    env_name                    = "${var.env_name}"
  }
}

resource "null_resource" "cname_traffic_manager" {
  count = "${var.traffic_manager_name != "" && var.service_names != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/add_trafficmanager.sh -s ${var.dns_subscription_id} -g ${var.resource_group_name} -z ${var.name} -t ${var.traffic_manager_name} -e \"${var.service_names}\""
  }

  triggers = {
    name                        = "${var.name}"
    dns_subscription_id         = "${var.dns_subscription_id}"
    resource_group_name         = "${var.resource_group_name}"
    service_principal_object_id = "${var.service_principal_object_id}"
    traffic_manager_name        = "${var.traffic_manager_name}"
    service_names               = "${var.service_names}"
    recreate_cname_records      = "${var.recreate_cname_records}"
  }

  depends_on = ["null_resource.dnszone"]
}
