resource "azurerm_application_insights" "app_insights" {
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  application_type    = "web"
}

resource "null_resource" "store_instrumentation_key" {
  count = "${var.name != "" && var.vault_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/add_instrumentation_key_secret.sh -i ${azurerm_application_insights.app_insights.instrumentation_key} -a ${azurerm_application_insights.app_insights.app_id} -v ${var.vault_name} -n ${var.instrumentation_key_secret_name} -s ${var.app_id_secret_name} -c \"${var.contributor_object_ids}\" -d ${var.subscription_id} -r ${var.resource_group_name} -m ${var.name}"
  }

  triggers = {
    name                   = "${var.name}"
    vault_name             = "${var.vault_name}"
    subscription_id        = "${var.subscription_id}"
    resource_group_name    = "${var.resource_group_name}"
    contributor_object_ids = "${var.contributor_object_ids}"
  }

  depends_on = ["azurerm_application_insights.app_insights"]
}
