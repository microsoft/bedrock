/*
variable "aad_server_app_id" {
  type = "string"
}

variable "aad_server_app_secret" {
  type = "string"
}

variable "aad_client_app_id" {
  type = "string"
}

variable "aad_tenant_id" {
  type = "string"
}
*/
variable "client_id" {
  type = "string"
}

variable "client_secret" {
  type = "string"
}

variable "ssh_public_key" {
  type = "string"
}

variable "flux_repo_url" {
  type = "string"
}

variable "gitops_url" {
  type = "string"
}

# generate a SSH key named identity: ssh-keygen -q -N "" -f ./identity
# add public key in gitops repo as deploy key with read/write access
# use private key to cretae kubernetes secret object
variable "gitops_ssh_key" {
  type    = "string"
  default = "./identity"
}
