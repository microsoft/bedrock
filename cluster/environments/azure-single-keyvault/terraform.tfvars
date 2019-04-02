# keyvault, vnet, and subnets are created seperately by azure-common-infra
keyvault_name = "my-keyvault"
keyvault_resource_group = "my-global-rg"

address_space = "<cidr for cluster address space>"
subnet_prefixes = "10.39.0.0/16"
vnet_name = "tim-vnet"
vnet_subnet_id = "/subscriptions/1d3bc944-c31f-41a9-a1ac-cafea961eba5/resourceGroups/tim-global-rg/providers/Microsoft.Network/virtualNetworks/tim-vnet/subnets/tim-subnet"

# cluster variables
agent_vm_count = "3"
agent_vm_size = "Standard_D4s_v3"

cluster_name = "azure-single-keyvault"
dns_prefix = "azure-single-keyvault"

gitops_ssh_url = "git@github.com:Microsoft/fabrikate-production-cluster-demo-materialized"
gitops_ssh_key = "./gitops_repo_key"
gitops_url_branch = "master"

resource_group_name = "azure-single-keyvault-rg"
resource_group_location = "westus2"

ssh_public_key = "<ssh public key>"

service_principal_id = "<service principal id>"
service_principal_secret = "<service principal secret>"
subscription_id = "<subscription id>"
tenant_id = "<tenant id>"
