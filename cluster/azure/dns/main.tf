module "azure-provider" {
  source = "../provider"
}

resource "azurerm_dns_zone" "dnszone" {
  name                = "${var.name}"
  resource_group_name = "${var.resource_group_name}"
  zone_type           = "Public"
}

resource "azurerm_dns_caa_record" "dnszone_caa" {
  name                = "caa"
  zone_name           = "${azurerm_dns_zone.dnszone.name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 300

  record {
    flags = 0
    tag   = "issue"
    value = "${var.caa_issuer}"
  }

  depends_on = ["azurerm_dns_zone.dnszone"]
}

resource "null_resource" "dnszone_contributor" {
  count = "${var.name != "" && var.service_principal_object_id != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/add_role_assignment.sh -g ${var.resource_group_name} -z ${var.name} -o ${var.service_principal_object_id}"
  }

  triggers = {
    name                        = "${var.name}"
    service_principal_object_id = "${var.service_principal_object_id}"
  }

  depends_on = ["azurerm_dns_zone.dnszone"]
}
