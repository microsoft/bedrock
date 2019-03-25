subscription_id = "azure subscription id"

tenant_id = "AAD tenant id"

login_service_principal_id = "replace with service principal with owner role in azure subscription"

login_service_principal_password = "replace me with service principal password"

traffic_manager_profile_name = "spinprofile"

traffic_manager_dns_name = "spintmdns"

traffic_manager_resource_group_name = "global-rg"

traffic_manager_resource_group_location = "centralus"

west_resource_group_name = "spin-west-rg"

west_resource_group_location = "westus2"

east_resource_group_name = "spin-east-rg"

east_resource_group_location = "eastus2"

central_resource_group_name = "spin-central-rg"

central_resource_group_location = "centralus"

cluster_name = "spincluster"

agent_vm_count = "3"

dns_prefix = "spindns"

service_principal_id = "<replace me>"

service_principal_secret = "<replace me>"

ssh_public_key = ""

gitops_ssh_url = ""

gitops_ssh_key = ""

gitops_east_path = ""

gitops_central_path = ""

gitops_west_path = ""

gitops_poll_interval = "5m"

central_address_space="172.20.0.0/16"

central_subnet_prefixes=["172.20.0.0/20"]

central_service_CIDR="172.21.0.0/16"

central_dns_IP="172.21.0.10"

central_docker_CIDR="172.17.0.1/16"

east_address_space="172.22.0.0/16"

east_subnet_prefixes=["172.22.0.0/20"]

east_service_CIDR="172.23.0.0/16"

east_dns_IP="172.23.0.10"

east_docker_CIDR="172.18.0.1/16"

west_address_space="172.24.0.0/16"

west_subnet_prefixes=["172.24.0.0/20"]

west_service_CIDR="172.25.0.0/16"

west_dns_IP="172.25.0.10"

west_docker_CIDR="172.19.0.1/16"