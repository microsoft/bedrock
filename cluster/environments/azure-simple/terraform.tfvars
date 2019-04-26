resource_group_name="resource-group-name"
resource_group_location="westus2"
cluster_name="cluster-name"
agent_vm_count = "3"
dns_prefix="dns-prefix"
service_principal_id = "client-id"
service_principal_secret = "client-secret"
ssh_public_key = "public-key"
gitops_ssh_url = "git@github.com:timfpark/fabrikate-cloud-native-manifests.git"
gitops_ssh_key = "<path to private gitops repo key>"
vnet_name = "<vnet name>"

#--------------------------------------------------------------
# Optional variables - Uncomment to use
#--------------------------------------------------------------
# gitops_url_branch = "release-123"
# gitops_poll_interval = "30s"
# gitops_path = "prod"
