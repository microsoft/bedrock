cluster_name=""
dns_prefix="dns-prefix"
service_principal_id = "client-id"
service_principal_secret = "client-secret"
ssh_public_key = "public-key"
gitops_url = "git@github.com:timfpark/fabrikate-cloud-native-materialized.git"

resource_group_name="<replace me with resource-group-name>"

resource_group_location="<replace me with resource-group-location>"

global_resource_group_name="<replace me with reource group name for traffic manager>"

global_resource_group_location="<replace me with reource group location for traffic manager>"

cluster01_name = "<replace me with cluster 01 name >"

cluster01_location = "<replace me with cluster 01 location >"

dns01_prefix="<replace me with cluster 01 dns >"

cluster02_name = "<replace me with cluster 02 name >"

cluster01_location = "<replace me with cluster 02 location >"

dns02_prefix="<replace me with cluster 02 dns >"

service_principal_id = "<replace me with servie principal app id >"

service_principal_secret = "<replace me with servie principal password >"

ssh_public_key = "<replace me with ssh public key for vm access in the cluster >"

gitops_url = "<replace me with gitops repo url for flux to minitor k8 manifests >"

flux_repo_url = "https://github.com/weaveworks/flux.git"

gitops_ssh_key = "<replace me with ssh private key file path>"