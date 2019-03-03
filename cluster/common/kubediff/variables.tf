# URL to get kubediff which will be installed in the Kubernetes cluster
variable "kubediff_repo_url" {
  type = "string"
  default = "https://github.com/weaveworks/kubediff.git"
}
 
variable "gitops_ssh_url" {
  description = "ssh git clone repository URL with Kubernetes manifests including services which runs in the cluster. Flux monitors this repo for Kubernetes manifest additions/changes preriodiaclly and apply them in the cluster."
  type = "string"
}

variable "output_directory" {
    type = "string"
    default = "./output"
}
 
variable "enable_kubediff" {
    type = "string"
    default = "true"
}
 
variable "kubeconfig_filename" {
    description = "Name of the kube config file saved to disk."
    type = "string"
    default = "bedrock_kube_config"
}
 
variable "kubeconfig_complete" {
    description = "Allows flux to wait for the kubeconfig completion write to disk. Workaround for the fact that modules themselves cannot have dependencies."
    type = "string"
}
 