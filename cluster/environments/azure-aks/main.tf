module "azure_aks" {
  source = "../../providers/azure-aks"

  cluster_name   = "my-dev-cluster"
  agent_vm_count = "3"
  agent_vm_size  = "Standard_DS3_v2"

  location   = "eastus2"
  admin_user = "ops"

  subnet_address_space = "10.200.0.0/16"
  vnet_address_space   = "10.200.0.0/16"
  first_master_ip      = "10.200.255.239"

  client_id     = "${var.client_id}"
  client_secret = "${var.client_secret}"

  ssh_public_key = "${var.ssh_public_key}"
}
