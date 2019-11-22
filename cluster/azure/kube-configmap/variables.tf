variable "subscription_id" {
  type = "string"
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
  default     = "true"
}

variable "k8s_namespace" {
  type        = "string"
  description = "target k8s namespaces where secret will be created"
}

variable "k8s_configmap_name" {
  type        = "string"
  description = "name of configmap"
}

variable "k8s_configmap_keys" {
  type = "string"
  description = "comma-separated keys used in configmap, length must be same as length of secret names"
}

variable "key_vault_name" {
  type        = "string"
  description = "name of key vault"
}

variable "key_vault_secret_names" {
  type        = "string"
  description = "comma-separated names of kv secret, each secret content is stored as plain text file (xml, json, yaml, conf, etc)"
}

variable "key_vault_secret_version" {
  type        = "string"
  description = "version of kv secret"
}