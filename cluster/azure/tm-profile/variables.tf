variable "traffic_manager_profile_name" {
  type = "string"
}

variable "traffic_manager_dns_name" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "resource_group_location"{
  type="string"
}

# variable "public_ips" {
#   description = "A list of public ips"
#   type        = "list"
#   default     = ["ip1", "ip2"]
# }

variable "tags" {
  description = "The tags to associate with the traffic maanger."
  type        = "map"

  default = {
    tag1 = ""
    tag2 = ""
  }
}
