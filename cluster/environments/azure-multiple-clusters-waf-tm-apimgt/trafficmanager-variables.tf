
variable "traffic_manager_resource_group_name" {
  type = "string"
  # default="terraformtest"
}

variable "traffic_manager_resource_group_location" {
  type = "string"
  default="centralus"
}

variable "traffic_manager_profile_name" {
  type = "string"
  default="glocaltf"
}

variable "traffic_manager_dns_name" {
  type = "string"
   default="glocaltf"
}

variable "traffic_manager_monitor_protocol" {
  type    = "string"
  default = "http"
}

variable "traffic_manager_monitor_port" {
  type    = "string"
  default = "80"
}