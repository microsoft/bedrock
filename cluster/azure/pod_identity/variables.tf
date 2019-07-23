variable "enable_pod_identity" {
  type    = "string"
  default = "true"
}

variable "resource_group_name" {
  type = "string"
}

variable "subscription_id" {
  type = "string"
}

variable "pod_identity_install_url" {
  type = "string"
  default = "https://raw.githubusercontent.com/Azure/aad-pod-identity/1.3.0-mic-1.4.0-nmi/deploy/infra/deployment-rbac.yaml"
}

variable "identity_name" {
  type = "string"
}

variable "output_directory" {
  type    = "string"
  default = "./output"
}

variable "kubeconfig_filename" {
  description = "Name of the kube config file saved to disk."
  type        = "string"
  default     = "bedrock_kube_config"
}

variable "pod_identity_recreate" {
  description = "Make any change to this value to trigger the reinstallation of pod identity script."
  type        = "string"
  default     = ""
}

variable "kubeconfig_complete" {
  description = "Allows pod identity to wait for the kubeconfig completion write to disk. Workaround for the fact that modules themselves cannot have dependencies."
  type        = "string"
}