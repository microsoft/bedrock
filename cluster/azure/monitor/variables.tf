variable "resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "app_insights_name" {
  type = "string"
}

variable "auto_mitigate" {
  type = "string"
  default = "true"
}

variable "sev3_enabled" {
  type = "string"
  default = "true"
}

variable "sev2_enabled" {
  type = "string"
  default = "false"
}

variable "frequency" {
  type = "string"
  default = "PT5M"
}

variable "window_size" {
  type = "string"
  default = "PT15M"
}

variable "tags" {
  type = "map"
  default = {}
}

variable "metric_namespace" {
  type = "string"
}

variable "unhandled_exception_metric_name" {
  type = "string"
}

variable "heartbeat_metric_name" {
  type = "string"
}

variable "aggregation" {
  type = "string"
  default = "Total"
}

variable "operator" {
  type = "string"
  default = "GreaterThan"
}

variable "threshold_sev3" {
  type = "string"
  default = 5
}

variable "threshold_sev2" {
  type = "string"
  default = 50
}

variable "heartbeat_frequency" {
  type = "string"
  default = "PT1H"
}

variable "heartbeat_window_size" {
  type = "string"
  default = "PT6H"
}

variable "heartbeat_threshold_sev3" {
  type = "string"
  default = 5
}

variable "heartbeat_threshold_sev2" {
  type = "string"
  default = 0
}

variable "pingable" {
  type = "string"
  default = "false"
}

variable "status_url" {
  type = "string"
  default = ""
}