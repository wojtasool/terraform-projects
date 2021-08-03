resource "libvirt_volume" "node_root_disk" {
  for_each = { for domain in local.domains : domain.name => domain }
  name     = "${each.key}.qcow2"
  pool     = "RAID10"
  source   = var.default_os_disk
}
