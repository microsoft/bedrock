variable "owners" {
  type = "string"
  description = "comma separated aad user object id who are granted to cluster cluster admins"
  default = []
}

variable "contributors" {
  type = "string"
  description = "comma separated aad group object id who are contributors to aks"
  default = []
}

variable "readers" {
  type = "string"
  description = "comma separated aad group object id who are readers to aks"
  default = []
}

variable "kubeconfigadmin_filename" {
  description = "Name of the admin kube config file saved to disk."
  type        = "string"
  default     = "admin_kube_config"
}

variable "kubeconfigadmin_done" {
  description = "Allows flux to wait for the admin kubeconfig completion write to disk. Workaround for the fact that modules themselves cannot have dependencies."
  type        = "string"
}