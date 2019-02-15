variable "traffic_manager_profile_name" {
  type = "string"
}

variable "traffic_manager_resource_group_name" {
  type = "string"
}

variable "public_ip_name" {
  type = "string"
}

variable "endpoint_name" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "resource_location" {
  type = "string"
}

variable "ip_address_filename" {
  type    = "string"
  default = "bedrock_public_ip_address"
}

variable "ipaddress_to_disk" {
  description = "This disables or enables the ip address output file from being written to disk."
  type        = "string"
  default     = "true"
}

variable "output_directory" {
  type    = "string"
  default = "./output"
}

variable "tags" {
  description = "The tags to associate with the public ip address."
  type        = "map"

  default = {
    tag1 = ""
    tag2 = ""
  }
}
