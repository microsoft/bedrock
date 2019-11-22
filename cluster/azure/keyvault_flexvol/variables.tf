variable "aks_subscription_id" {
  type = "string"
}

variable "output_directory" {
  type    = "string"
  default = "./output"
}

variable "kubeconfigadmin_filename" {
  description = "Name of the admin kube config file saved to disk. (because aad integration, regular kube config doesn't have credential)"
  type        = "string"
  default     = "admin_kube_config"
}

variable "kubeconfig_complete" {
  description = "Allows flex volume deployment to wait for the kubeconfig completion write to disk. Workaround for the fact that modules themselves cannot have dependencies."
  type        = "string"
  default     = "true"
}

variable "env_name" {
  type        = "string"
  description = "target aks cluster env, allowed values: dev, int, test, ppe, prod"
}

variable "flexvol_version" {
  type = "string"
}

variable "flexvol_namespace" {
  type    = "string"
  default = "kv"
}
