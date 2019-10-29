resource "azurerm_monitor_action_group" "email-alert" {
  name                = "email-dri"
  resource_group_name = "${var.resource_group_name}"
  short_name          = "email-dri"

  email_receiver {
    name          = "1csdri"
    email_address = "1csdri@microsoft.com"
  }

  email_receiver {
    name          = "xiaodoli"
    email_address = "xiaodoli@microsoft.com"
  }
}

resource "azurerm_monitor_action_group" "sms-alert" {
  name                = "sms-dri"
  resource_group_name = "${var.resource_group_name}"
  short_name          = "sms-dri"

  email_receiver {
    name          = "1csdri"
    email_address = "1csdri@microsoft.com"
  }

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
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  application_type    = "web"
}

resource "azurerm_monitor_metric_alert" "sev3" {
  name                = "sev3_alert"
  resource_group_name = "${var.resource_group_name}"
  scopes              = ["${data.azurerm_application_insights.app_insights.id}"]
  description         = "Sev3 alert will be triggered when aggregated number goes beyond threshold within specified window"
  auto_mitigate       = "${var.auto_mitigate}"
  enabled             = "${var.enabled}"
  frequency           = "${var.frequency}"
  severity            = 3
  window_size         = "${var.window_size}"
  tags                = "${var.tags}"

  criteria {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.metric_name}"
    aggregation      = "${var.aggregation}"
    operator         = "${var.operator}"
    threshold        = "${var.threshold_sev3}"
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.email-alert.id}"
  }
}

resource "azurerm_monitor_metric_alert" "sev2" {
  name                = "sev2_alert"
  resource_group_name = "${var.resource_group_name}"
  scopes              = ["${data.azurerm_application_insights.app_insights.id}"]
  description         = "Sev2 alert will be triggered when aggregated number goes beyond threshold within specified window"
  auto_mitigate       = "${var.auto_mitigate}"
  enabled             = "${var.enabled}"
  frequency           = "${var.frequency}"
  severity            = 2
  window_size         = "${var.window_size}"
  tags                = "${var.tags}"

  criteria {
    metric_namespace = "${var.metric_namespace}"
    metric_name      = "${var.metric_name}"
    aggregation      = "${var.aggregation}"
    operator         = "${var.operator}"
    threshold        = "${var.threshold_sev2}"
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.sms-alert.id}"
  }
}

resource "azurerm_application_insights_web_test" "ping" {
  name = "webtest"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  application_insights_id = "${data.azurerm_application_insights.app_insights.id}"
  kind = "ping"
  frequency = 300
  timeout = 15
  enabled = "${var.pingable}"
  geo_locations = ["west us", "east us"]

  configuration = <<XML
<WebTest Name="WebTest1" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="${var.status_url}" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML
}

resource "azurerm_metric_alertrule" "availability" {
  name                = "availability"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  description = "An alert rule to watch the status ping results"
  enabled = "${var.pingable}"

  resource_id = "${azurerm_application_insights_web_test.ping.id}"
  metric_name = "availability"
  operator    = "GreaterThan"
  threshold   = 0.9
  aggregation = "Average"
  period      = "PT5M"

  email_action {
    send_to_service_owners = false

    custom_emails = [
      "1csdri@microsoft.com",
    ]
  }
}