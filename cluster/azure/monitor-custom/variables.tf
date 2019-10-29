variable "resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "app_insights_name" {
  type = "string"
}

variable "service_name" {
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

variable "metric_namespace" {
  type = "string"
}

variable "metric_name" {
  type = "string"
}

variable "tags" {
  type = "map"
  default = {}
}

variable "threshold_sev3" {
  type = "string"
  default = 10
}

variable "threshold_sev2" {
  type = "string"
  default = 50
}

variable "aggregation" {
  type = "string"
  default = "Total"
}

variable "operator" {
  type = "string"
  default = "GreaterThan"
}

variable "frequency" {
  type = "string"
  default = "PT1H"
}

variable "window_size" {
  type = "string"
  default = "PT6H"
}