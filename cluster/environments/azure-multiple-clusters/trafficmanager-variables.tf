variable "traffic_manager_resource_group_name" {
  type = "string"
}

variable "traffic_manager_profile_name" {
  type = "string"
}

variable "traffic_manager_dns_name" {
  type = "string"
}

variable "traffic_manager_monitor_protocol" {
  type    = "string"
  default = "http"
}

variable "traffic_manager_monitor_port" {
  type    = "string"
  default = "80"
}
