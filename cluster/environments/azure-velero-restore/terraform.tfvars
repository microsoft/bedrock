#--------------------------------------------------------------
# Velero restore variables.
#--------------------------------------------------------------
velero_bucket                          = "<blob container name>"
velero_backup_location_config          = "resourceGroup=<resource group here>,storageAccount=<storage account name here>"
velero_volume_snapshot_location_config = "apiTimeout=10m"
velero_backup_name                     = "<backup name>"
velero_delete_pod                      = "true"

#--------------------------------------------------------------
# keyvault, vnet, and subnets are created seperately by azure-common-infra
#--------------------------------------------------------------
keyvault_name           = "my-keyvault"
keyvault_resource_group = "my-global-rg"

address_space   = "<cidr for cluster address space>"
subnet_prefixes = "10.39.0.0/16"
vnet_name       = "my-vnet"
vnet_subnet_id  = "/subscriptions/<subid>/resourceGroups/<my-global-rg>/providers/Microsoft.Network/virtualNetworks/<my-vnet>/subnets/<my-subnet>"

#--------------------------------------------------------------
# Cluster variables
#--------------------------------------------------------------
agent_vm_count = "3"
agent_vm_size  = "Standard_D4s_v3"

cluster_name = "azure-single-keyvault"
dns_prefix   = "azure-single-keyvault"

gitops_ssh_url = "git@github.com:Microsoft/fabrikate-production-cluster-demo-materialized"
gitops_ssh_key = "./gitops_repo_key"

resource_group_name     = "azure-single-keyvault-rg"

ssh_public_key = "<ssh public key>"

service_principal_id     = "<service principal id>"
service_principal_secret = "<service principal secret>"
subscription_id          = "<subscription id>"
tenant_id                = "<tenant id>"

#--------------------------------------------------------------
# Optional variables - Uncomment to use
#--------------------------------------------------------------
# gitops_url_branch = "release-123"
# gitops_poll_interval = "30s"
# gitops_path = "prod"
