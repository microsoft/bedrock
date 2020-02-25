variable "traffic_manager_profile_name" {
  type = string
}

variable "traffic_manager_dns_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "traffic_manager_monitor_protocol" {
  type    = string
  default = "http"
}

variable "traffic_manager_monitor_port" {
  type    = string
  default = "80"
}

variable "tags" {
  description = "The tags to associate with the traffic maanger."
  type        = map

  default = {
    tag1 = ""
    tag2 = ""
  }
}
