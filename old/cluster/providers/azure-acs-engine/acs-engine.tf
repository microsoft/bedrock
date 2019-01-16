resource "azurerm_resource_group" "cluster" {
  name     = "${var.cluster_name}-rg"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "cluster" {
  name                = "${var.cluster_name}-vnet"
  address_space       = ["${var.vnet_address_space}"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cluster.name}"
}

resource "azurerm_subnet" "cluster" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = "${azurerm_resource_group.cluster.name}"
  address_prefix       = "${var.subnet_address_space}"
  virtual_network_name = "${azurerm_virtual_network.cluster.name}"
}

data "template_file" "acs_engine_config" {
  template = "${file("${path.module}/acs-engine-template.json")}"

  vars {
    version = "${var.kubernetes_version}"

    master_vm_count = "${var.master_vm_count}"
    master_vm_size  = "${var.master_vm_size}"
    agent_vm_count  = "${var.agent_vm_count}"
    agent_vm_size   = "${var.agent_vm_size}"

    admin_user = "${var.admin_user}"
    ssh_key    = "${trimspace(var.ssh_public_key)}"

    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"

    dns_prefix      = "${var.cluster_name}"
    subnet_id       = "${azurerm_subnet.cluster.id}"
    first_master_ip = "${var.first_master_ip}"
    vnet_cidr       = "${var.subnet_address_space}"
  }
}

resource "null_resource" "generate_acs_engine_config" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.acs_engine_config.rendered}' > deployment/acs-engine-cluster.json"
  }

  depends_on = ["data.template_file.acs_engine_config"]
}

# Locally run the ACS Engine to produce the Azure Resource Template for the K8s cluster
resource "null_resource" "generate_acs_engine_deployment" {
  provisioner "local-exec" {
    command = "acs-engine generate deployment/acs-engine-cluster.json --output-directory deployment/acs-engine"
  }

  depends_on = ["null_resource.generate_acs_engine_config"]
}

# Locally run the Azure 2.0 CLI to create the resource deployment
resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "az group deployment create --name ${var.cluster_name} --resource-group ${var.cluster_name}-rg --template-file ./deployment/acs-engine/azuredeploy.json --parameters @./deployment/acs-engine/azuredeploy.parameters.json"
  }

  depends_on = ["null_resource.generate_acs_engine_deployment"]
}

# Merge k8s config from acs-engine
resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command = "KUBECONFIG=./deployment/acs-engine/kubeconfig/kubeconfig.${var.location}.json:~/.kube/config kubectl config view --flatten > merged-config && mv merged-config ~/.kube/config"
  }

  depends_on = ["null_resource.cluster"]
}

resource "null_resource" "helm" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/tiller.yaml && helm init --service-account tiller --upgrade --wait"
  }

  depends_on = ["null_resource.kubectl"]
}
