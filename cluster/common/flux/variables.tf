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
}

variable "output_directory" {
    type = "string"
    default = "./output"
}

variable "enable_flux" {
    type = "string"
    default = "true"
}

variable "kubeconfig_filename" {
    description = "Name of the kube config file saved to disk."
    type = "string"
    default = "bedrock_kube_config"
}

variable "flux_recreate" {
    description = "Make any change to this value to trigger the recreation of the flux execution script."
    type = "string"
    default = ""
}