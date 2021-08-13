# URL to get flux which will be installed in the Kubernetes cluster
variable "flux_repo_url" {
  type    = string
  default = "https://github.com/fluxcd/flux.git"
}

# container registry to download flux image
variable "flux_image_repository" {
  type    = string
  default = "docker.io/fluxcd/flux"
}

# flux version to download source from git repo and container image from the registry
variable "flux_image_tag" {
  type    = string
  default = "1.18.0"
}

variable "gitops_path" {
  type = string
}

variable "gitops_poll_interval" {
  type    = string
  default = "5m"
}

variable "gitops_label" {
  type    = string
  default = "flux-sync"
}

variable "gitops_ssh_url" {
  description = "ssh git clone repository URL with Kubernetes manifests including services which runs in the cluster. Flux monitors this repo for Kubernetes manifest additions/changes preriodiaclly and apply them in the cluster."
  type        = string
}

variable "gitops_url_branch" {
  description = "Git branch associated with the gitops_ssh_url where flux checks for the raw kubernetes yaml files to deploy to the cluster."
  type        = string
  default     = "main"
}

variable "acr_enabled" {
  type    = string
  default = "true"
}

variable "gc_enabled" {
  type    = string
  default = "true"
}

# generate a SSH key named identity: ssh-keygen -q -N "" -f ./identity
# or use existing ssh public/private key pair
# add deploy key in gitops repo using public key with read/write access
# assign/specify private key to "gitops_ssh_key_path" variable that will be used to cretae kubernetes secret object
# flux use this key to read manifests in the git repo
variable "gitops_ssh_key_path" {
  type = string
}

variable "output_directory" {
  type    = string
  default = "./output"
}

variable "enable_flux" {
  type    = string
  default = "true"
}

variable "kubeconfig_filename" {
  description = "Name of the kube config file saved to disk."
  type        = string
  default     = "bedrock_kube_config"
}

variable "flux_recreate" {
  description = "Make any change to this value to trigger the recreation of the flux execution script."
  type        = string
  default     = ""
}

variable "kubeconfig_complete" {
  description = "Allows flux to wait for the kubeconfig completion write to disk. Workaround for the fact that modules themselves cannot have dependencies."
  type        = string
}

variable "flux_clone_dir" {
  description = "Name of the directory to clone flux repo and deploy in the cluster."
  type        = string
}

variable "api_server_available" {
  description = "Has the api server proces run"
  type        = string
}
