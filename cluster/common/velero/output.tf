output "velero_done" {
  value = join("", null_resource.velero_restore.*.id)
}
