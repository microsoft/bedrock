variable "resource_group_name" {
    type = "string"
}

variable "resource_group_location" {
    type = "string"
}

variable "cluster_name" {
    type = "string"
}

variable "agent_vm_count" {
    type = "string"
    default = "3"
}

variable "dns_prefix" {
    type = "string"
}

variable "ssh_public_key" {
    type = "string"
}

variable "service_principal_id" {
    type = "string"
}

variable "service_principal_secret" {
    type = "string"
}

variable "gitops_ssh_url" {
  type = "string"
}

variable "gitops_ssh_key" {
  type    = "string"
}

variable "keyvault_name" {
    type    = "string"
}

variable "secret_name" {
    type    = "string"
    default = ""
}

variable "secret_value" {
    type    = "string"
    default = ""
}

variable "flux_recreate" {
    description = "Make any change to this value to trigger the recreation of the flux execution script."
    type = "string"
    default = ""
}

variable "flexvol_recreate" {
    description = "Make any change to this value to trigger the recreation of the flex volume execution script."
    type = "string"
    default = ""
}