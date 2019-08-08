variable "owners" {
  type = "list"
  description = "list of user alias who are granted to cluster cluster admins"
  default = []
}

variable "contributors" {
  type = "list"
  description = "list of groups who are contributors to aks"
  default = []
}

variable "readers" {
  type = "list"
  description = "list of groups who are readers to aks"
  default = []
}

variable "output_directory" {
  type    = "string"
  default = "./output"
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