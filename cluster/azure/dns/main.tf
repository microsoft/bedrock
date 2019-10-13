module "azure-provider" {
  source = "../provider"
}

resource "null_resource" "dnszone" {
  count = "${var.name != "" && var.resource_group_name != "" && var.service_principal_object_id != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/ensure_dns_zone.sh -g ${var.resource_group_name} -z ${var.name} -c ${var.caa_issuer} -o ${var.service_principal_object_id} -e ${var.env_name}"
  }

  triggers = {
    name                        = "${var.name}"
    resource_group_name         = "${var.resource_group_name}"
    service_principal_object_id = "${var.service_principal_object_id}"
    caa_issuer                  = "${var.caa_issuer}"
    env_name                    = "${var.env_name}"
  }
}
