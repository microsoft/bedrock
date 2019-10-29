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

variable "enabled" {
  type = "string"
  default = "true"
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
}

variable "metric_namespace" {
  type = "string"
}

variable "metric_name" {
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

variable "pingable" {
  type = "string"
  default = "false"
}