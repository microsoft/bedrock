variable "resource_group_name" {
  type = "string"
}

variable "resource_group_location" {
  type = "string"
}

variable "cluster01_name" {
  type = "string"
}

variable "cluster01_location" {
  type = "string"
}

variable "dns01_prefix" {
  type = "string"
}

variable "cluster02_name" {
  type = "string"
}

variable "cluster02_location" {
  type = "string"
}

variable "dns02_prefix" {
  type = "string"
}

variable "client_id" {
  type = "string"
}

variable "client_secret" {
  type = "string"
}

variable "agent_vm_count" {
  type = "string"
}

variable "agent_vm_size" {
  type = "string"
}

variable "kubernetes_version" {
  type    = "string"
  default = "1.12.4"
}

variable "admin_user" {
  type = "string"
}

variable "ssh_public_key" {
  type = "string"
}

variable "subnet_address_space" {
  type = "string"
}

variable "vnet_address_space" {
  type = "string"
}

# URL to get flux which will be installed in the Kubernetes cluster
variable "flux_repo_url" {
  type    = "string"
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
  type = "string"
}

variable "output_directory" {
  type = "string"
}

variable "global_resource_group_name" {
  type = "string"
}

variable "global_resource_group_location" {
  type = "string"
}

variable "ip_allocation_method" {
  type    = "string"
  default = "Static"
}

variable "aks_client_role_assignment_role" {
  type    = "string"
  default = "Contributor"
}

variable "traffic_manager_routing_method" {
  type    = "string"
  default = "Weighted"
}

variable "traffic_manager_endpoint_type" {
  type    = "string"
  default = "azureEndpoints"
}
