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
variable "cluster_id" {
  type = "string"
  default = "my-dev-cluster"
}

variable "location" {
  type = "string"
  default = "westus2"
}

variable "client_id" {
  type = "string"
}

variable "client_secret" {
  type = "string"
}

variable "ssh_public_key" {
  type = "string"
}

# URL to get flux which will be installed in the Kubernetes cluster
variable "flux_repo_url" {
  type = "string"
  default = "https://github.com/weaveworks/flux.git"
}

# URL of git repo with Kubernetes manifests including services which runs in the cluster
# flux monitors this repo for Kubernetes manifest additions/changes preriodiaclly and apply them in the cluster
variable "gitops_url" {
  type = "string"
}

# generate a SSH key named identity: ssh-keygen -q -N "" -f ./identity
# or use existing ssh public/private key pair
# add deploy key in gitops repo using public key with read/write access
# assign/specify private key to "gitops_ssh_key" variable that will be used to cretae kubernetes secret object
# flux use this key to read manifests in the git repo 
variable "gitops_ssh_key" {
  type    = "string"
  default = "./identity"
}

# generate a random unique key to be apended to cluster name
locals {
  key_id = "${random_integer.ri.result}"
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
