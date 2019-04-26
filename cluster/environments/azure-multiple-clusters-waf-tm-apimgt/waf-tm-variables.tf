
variable "resource_group_name_east" {
  description = "Name of the eastus resource group already created."
}


variable "resource_group_name_west" {
  description = "Name of the westus resource group already created."
}


variable "resource_group_name_central" {
  description = "Name of the centralus resource group already created."
}


variable "vnet_east" {
  description = "Name of the eastus vnet already created."
}


variable "vnet_west" {
  description = "Name of the westus vnet already created."
}


variable "vnet_central" {
  description = "Name of the centralus vnet already created."
}



# service variables
variable "prefix" {
  default = "tfdemo"
}
variable "location" {
  default = "eastus"
}
variable "tag" {
  default = "demo"
}


variable "tags" {
  description = "The tags to associate with the traffic maanger."
  type        = "map"

  default = {
    tag1 = ""
    tag2 = ""
  }
}
