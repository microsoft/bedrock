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

variable "agent_vm_size" {
    type = "string"
    default = "Standard_D2s_v3"
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

variable "subscription_id" {
  type    = "string"
}

variable "tenant_id" {
  type    = "string"
}

variable "gitops_path" {
    type = "string"
}

variable "gitops_ssh_url" {
  type = "string"
}

variable "gitops_ssh_key" {
  type    = "string"
}

variable "tfstate_storage_account_name" {
  type    = "string"
  default = ""
}

variable "tfstate_storage_account_access_key" {
  type    = "string"
  default = ""
}

variable "tfstate_container_name" {
  type    = "string"
  default = "bedrockstate"
}

variable "tfstate_key" {
  type    = "string"
  default = "bedrock.dev.tfstate"
}

variable "flux_recreate" {
    description = "Make any change to this value to trigger the recreation of the flux execution script."
    type = "string"
    default = ""
}

variable "service_CIDR" {
  default = "10.0.0.0/16"
  description ="Used to assign internal services in the AKS cluster an IP address. This IP address range should be an address space that isn't in use elsewhere in your network environment. This includes any on-premises network ranges if you connect, or plan to connect, your Azure virtual networks using Express Route or a Site-to-Site VPN connections."
  type = "string"
}

variable "dns_IP" {
  default = "10.0.0.10"
  description = "should be the .10 address of your service IP address range"
  type = "string"
}

variable "docker_CIDR" {
  default = "172.17.0.1/16"
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Default of 172.17.0.1/16."
}