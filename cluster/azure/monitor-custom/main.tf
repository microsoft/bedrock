resource "azurerm_monitor_action_group" "email-dri" {
  name                = "email-dri-group"
  resource_group_name = "${var.resource_group_name}"
  short_name          = "email-dri"

  # email_receiver {
  #   name          = "1csdri"
  #   email_address = "1csdri@microsoft.com"
  # }

  email_receiver {
    name          = "xiaodoli"
    email_address = "xiaodoli@microsoft.com"
  }
}

resource "azurerm_monitor_action_group" "sms-oncall" {
  name                = "sms-oncall"
  resource_group_name = "${var.resource_group_name}"
  short_name          = "sms-dri"

  # email_receiver {
  #   name          = "1csdri"
  #   email_address = "1csdri@microsoft.com"
  # }

  email_receiver {
    name          = "xiaodoli"
    email_address = "xiaodoli@microsoft.com"
  }

  sms_receiver {
    name         = "oncall"
    country_code = "1"
    phone_number = "2407517601"
  }
}

data "azurerm_application_insights" "app_insights" {
  name                = "${var.app_insights_name}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_monitor_metric_alert" "sev3" {
  count = "${var.metric_name != "" && var.sev3_enabled == "true" ? 1 : 0}"

  name                = "${var.metric_namespace}_${var.metric_name}_sev3"
  resource_group_name = "${var.resource_group_name}"
  scopes              = ["${data.azurerm_application_insights.app_insights.id}"]
  description         = "Sev3 alert will be triggered when aggregated number goes beyond threshold within specified window"
  auto_mitigate       = "${var.auto_mitigate}"
  enabled             = "${var.sev3_enabled}"
  frequency           = "${var.frequency}"
  window_size         = "${var.window_size}"
  severity            = 3
  tags                = "${var.tags}"

  criteria {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.metric_name}"
    aggregation      = "${var.aggregation}"
    operator         = "${var.operator}"
    threshold        = "${var.threshold_sev3}"
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.email-dri.id}"
  }
}

resource "azurerm_monitor_metric_alert" "sev2" {
  count = "${var.metric_name != "" && var.sev2_enabled == "true" ? 1 : 0}"

  name                = "${var.metric_namespace}__${var.metric_name}_sev2"
  resource_group_name = "${var.resource_group_name}"
  scopes              = ["${data.azurerm_application_insights.app_insights.id}"]
  description         = "Sev2 alert will be triggered when aggregated number goes beyond threshold within specified window"
  auto_mitigate       = "true"
  enabled             = "${var.sev2_enabled}"
  frequency           = "${var.frequency}"
  window_size         = "${var.window_size}"
  severity            = 2
  tags                = "${var.tags}"

  criteria {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.metric_name}"
    aggregation      = "${var.aggregation}"
    operator         = "${var.operator}"
    threshold        = "${var.threshold_sev2}"
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.sms-oncall.id}"
  }
}
