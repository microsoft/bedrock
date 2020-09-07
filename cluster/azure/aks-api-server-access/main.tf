module "common-provider" {
  source = "../../common/provider"
}

locals {
  # does access to the api server need opening up?
  api_server_access_needed = length(var.kube_api_server_authorized_ip_ranges) > 0 ? true : false
  
  # what does the opening the server look like?  a specified IP will be added, if empty string, the whole api server will be open
  api_server_temporary_access_allow_all = var.kube_api_server_temp_authorized_ip == "" ? true : false

  # current api server list
  api_server_access_list = join(",", var.kube_api_server_authorized_ip_ranges)

  # setup the command line
  api_access_script = "${path.module}/kube_api_server_access.sh"

  # open api server access
  open_api_server_access_args = local.api_server_temporary_access_allow_all ? "-g ${var.resource_group_name} -n ${var.cluster_name} -a -s ''" : "-g ${var.resource_group_name} -n ${var.cluster_name} -a -i ${var.kube_api_server_temp_authorized_ip}"

  # close api server access
  close_api_server_access_args = "-g ${var.resource_group_name} -n ${var.cluster_name} -a -s '${local.api_server_access_list}'"
}

resource "null_resource" "open_api_server" {
  count = local.api_server_access_needed ? 1 : 0

  provisioner "local-exec" {
    command = "${local.api_access_script} ${local.open_api_server_access_args}"
  }

  triggers = {
    kubeconfig_complete = var.kubeconfig_complete
  }
}

resource "null_resource" "close_api_server" {
  count = local.api_server_access_needed ? 1 : 0

  provisioner "local-exec" {
    command = "${local.api_access_script} ${local.close_api_server_access_args}"
  }

  triggers = {
    flux_done = var.flux_done
    kubediff_done = var.kubediff_done
  }
}