#resource "libvirt_volume" "node_root_disk" {
#  for_each = { for domain in local.domains : domain.name => domain }
#  name     = "${each.key}.qcow2"
#  pool     = "FAST"
#  source   = var.default_os_disk
#}

#(try("${each.value.cpu}", 0) == 0)
