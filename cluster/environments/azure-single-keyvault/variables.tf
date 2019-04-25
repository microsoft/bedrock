variable "acr_enabled" {
  type    = "string"
  default = "true"
}

variable "address_space" {
  type = "string"
}

variable "agent_vm_count" {
  type = "string"
}

variable "agent_vm_size" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "dns_prefix" {
  type = "string"
}

variable "flux_recreate" {
  description = "Make any change to this value to trigger the recreation of the flux execution script."
  type        = "string"
  default     = ""
}

# container registry to download flux image 
variable "flux_image_repository" {
  type    = "string"
  default = "docker.io/weaveworks/flux"
}

# flux version to download source from git repo and container image from the registry
variable "flux_image_tag" {
  type    = "string"
  default = "1.12.1"
}

variable "gitops_poll_interval" {
  type    = "string"
  default = "5m"
}

variable "gitops_ssh_url" {
  type = "string"
}

variable "gitops_ssh_key" {
  type = "string"
}

variable "gitops_path" {
  type    = "string"
  default = ""
}

variable "keyvault_name" {
  type = "string"
}

variable "keyvault_resource_group" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "resource_group_location" {
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

variable "subnet_prefixes" {
  type = "string"
}

variable "vnet_subnet_id" {
  type = "string"
}
