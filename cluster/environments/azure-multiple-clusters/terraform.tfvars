cluster_name="cluster-name"
agent_vm_count = "3"
dns_prefix="dns-prefix"
service_principal_id = "client-id"
service_principal_secret = "client-secret"
ssh_public_key = "public-key"
gitops_ssh_url = "git@github.com:timfpark/fabrikate-cloud-native-manifests.git"
gitops_ssh_key = "path-to-private-key"
gitops_poll_interval = "5m"

traffic_manager_profile_name = "spinprofile"
traffic_manager_dns_name = "spintmdns"
traffic_manager_resource_group_name = "global-rg"
traffic_manager_resource_group_location = "centralus"

west_resource_group_name = "spin-west-rg"
west_resource_group_location = "westus2"
gitops_west_path = ""

east_resource_group_name = "spin-east-rg"
east_resource_group_location = "eastus2"
gitops_east_path = ""

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




west_address_space="172.24.0.0/16"

west_subnet_prefixes=["172.24.0.0/20"]

west_service_CIDR="172.25.0.0/16"

west_dns_IP="172.25.0.10"

west_docker_CIDR="172.19.0.1/16"
