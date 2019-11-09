provider "azurerm" {
  subscription_id = "${var.subscription_id}"
}

resource "null_resource" "app_insights" {
  count = "${var.name != "" && var.resource_group_name != "" && var.location != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "pwsh ${path.module}/ensure_app_insights.ps1 -AppInsightsName \"${var.name}\" -SubscriptionId ${var.subscription_id} -ResourceGroupName ${var.resource_group_name} -Location \"${var.location}\""
  }

  triggers = {
    name                   = "${var.name}"
    subscription_id        = "${var.subscription_id}"
    resource_group_name    = "${var.resource_group_name}"
  }
}

resource "null_resource" "store_instrumentation_key" {
  count = "${var.name != "" && var.vault_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/add_instrumentation_key_secret.sh -g ${var.resource_group_name} -a ${var.name} -v ${var.vault_name} -n ${var.instrumentation_key_secret_name} -s ${var.app_id_secret_name} -c \"${var.contributor_object_ids}\" -d ${var.subscription_id}"
  }

  triggers = {
    name                   = "${var.name}"
    vault_name             = "${var.vault_name}"
    subscription_id        = "${var.subscription_id}"
    resource_group_name    = "${var.resource_group_name}"
    contributor_object_ids = "${var.contributor_object_ids}"
  }

  depends_on = ["null_resource.app_insights"]
}
