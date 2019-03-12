variable "resource_group_name" {
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



variable "flexvol_deployment_url" {
    description = "The url to the yaml file for deploying the KeyVault flex volume."
    type = "string"
    default = "https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/31f593250045e8dc861e13a8e943284787b7f17e/deployment/kv-flexvol-installer.yaml"
}

variable "output_directory" {
    type = "string"
    default = "./output"
}

variable "enable_flexvol" {
    type = "string"
    default = "true"
}

variable "keyvault_name" {
    description = "The name of the keyvault that will be associated with the flex volume."
    type = "string"
}

variable "flexvol_recreate" {
    description = "Make any change to this value to trigger the recreation of the flex volume execution script."
    type = "string"
    default = ""
}

variable "kubeconfig_filename" {
    description = "Name of the kube config file saved to disk."
    type = "string"
    default = "bedrock_kube_config"
}

variable "kubeconfig_complete" {
    description = "Allows flex volume deployment to wait for the kubeconfig completion write to disk. Workaround for the fact that modules themselves cannot have dependencies."
    type = "string"
}