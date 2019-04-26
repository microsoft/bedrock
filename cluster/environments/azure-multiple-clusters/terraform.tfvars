#--------------------------------------------------------------
# Cluster common
#--------------------------------------------------------------
cluster_name = "spincluster"

agent_vm_count = "3"

dns_prefix = "spindns"

service_principal_id = ""

service_principal_secret = ""

ssh_public_key = ""

#--------------------------------------------------------------
# Flux gitops common
#--------------------------------------------------------------
gitops_ssh_url = "git@github.com:sarath-p/vote-flux.git"

gitops_ssh_key = ""

#--------------------------------------------------------------
# Traffic Manager
#--------------------------------------------------------------
traffic_manager_profile_name = ""

traffic_manager_dns_name = ""

traffic_manager_resource_group_name = ""

traffic_manager_resource_group_location = ""

#--------------------------------------------------------------
# West
#--------------------------------------------------------------
west_resource_group_name = ""

west_resource_group_location = ""

gitops_west_path = ""

#--------------------------------------------------------------
# East
#--------------------------------------------------------------
east_resource_group_name = ""

east_resource_group_location = ""

gitops_east_path = ""

#--------------------------------------------------------------
# Central
#--------------------------------------------------------------
central_resource_group_name = ""

central_resource_group_location = ""

gitops_central_path = ""

#--------------------------------------------------------------
# Optional variables - Uncomment to use
#--------------------------------------------------------------
# gitops_central_url_branch = "master"
# gitops_east_url_branch = "master"
# gitops_west_url_branch = "master"
# gitops_poll_interval = "30s"