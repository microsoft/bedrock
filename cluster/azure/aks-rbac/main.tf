module "azure-provider" {
  source = "../provider"
}

resource "null_resource" "aks_roleassignment" {
  count = "${var.owners != "" || var.contributors != "" || var.readers != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done};KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} ${path.module}/apply_aad_rbac.sh -o \"${var.owners}\"  -c \"${var.contributors}\" -r \"${var.readers}\" -n \"${var.owner_groups}\" -d \"${var.contributor_groups}\" -s \"${var.reader_groups}\" -a \"${path.module}/cluster_contributor.yaml\" -b \"${path.module}/cluster_reader.yaml\""
  }

  triggers = {
    owners             = "${var.owners}"
    contributors       = "${var.contributors}"
    readers            = "${var.readers}"
    owner_groups       = "${var.owner_groups}"
    contributor_groups = "${var.contributor_groups}"
    reader_groups      = "${var.reader_groups}"
  }
}
