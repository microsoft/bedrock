
#--------------------------------------------------------------
# keyvault, vnet, and subnets are created seperately by azure-common-infra
#--------------------------------------------------------------
keyvault_name = "my-keyvault"
keyvault_resource_group = "my-global-rg"

address_space = "<cidr for cluster address space>"
subnet_prefixes = "10.39.0.0/16"
vnet_name = "<vnet name>"
subnet_name = "<subnet_name>"

#--------------------------------------------------------------
# CosmosDB & MongoDB variables
#--------------------------------------------------------------

# resource_group_name = "" # Piggybacking off global rg for CosmosDB
cosmos_db_name = "my-cosmos-db-name"
mongo_db_name = "my-mongo-db-name"
# cosmos_db_offer_type = "Standard" - Optional field

#--------------------------------------------------------------
# Cluster variables
#--------------------------------------------------------------
agent_vm_count = "3"
agent_vm_size = "Standard_D4s_v3"

cluster_name = "azure-single-keyvault"
dns_prefix = "azure-single-keyvault"

gitops_ssh_url = "git@github.com:Microsoft/fabrikate-production-cluster-demo-materialized"
gitops_ssh_key = "./gitops_repo_key"

resource_group_name = "azure-single-keyvault-rg"
resource_group_location = "westus2"

ssh_public_key = "<ssh public key>"

service_principal_id = "<service principal id>"
service_principal_secret = "<service principal secret>"

#--------------------------------------------------------------
# Optional variables - Uncomment to use
#--------------------------------------------------------------
# gitops_url_branch = "release-123"
# gitops_poll_interval = "30s"
# gitops_path = "prod"
