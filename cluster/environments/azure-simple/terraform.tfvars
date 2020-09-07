resource_group_name      = "<resource-group-name>"
cluster_name             = "<cluster-name>"
agent_vm_count           = "3"
dns_prefix               = "<dns-prefix>"
service_principal_id     = "<client-id>"
service_principal_secret = "<client-secret>"
ssh_public_key           = "ssh-rsa ..."                             # from node-ssh-key.pub
gitops_ssh_url           = "git@github.com:<github-user>/<repo>.git" # ssh url to manifest repo
gitops_ssh_key_path      = "/home/<user>/.ssh/gitops-ssh-key"        # path to private gitops repo key
vnet_name                = "<vnet name>"

#--------------------------------------------------------------
# Optional variables - Uncomment to use
#--------------------------------------------------------------
# gitops_url_branch = "release-123"
# gitops_poll_interval = "30s"
# gitops_path = "prod"
# network_policy = "calico"
# oms_agent_enabled = "false"
# gitops_label = "custom-flux-sync"
