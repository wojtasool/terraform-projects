resource "local_file" "definitions" {
  content  = jsonencode({ "defaults" = { "default_os_disk_template" : local.default_boot_disk, "default_os_disk_template_pool" : local.default_disk_pool }, "domains" = local.domains })
  filename = "spec.json"
}


data "template_file" "user_data" {
  for_each = { for domain in local.domains_disks : domain.name => domain }
  template = file("files/cloud_init.cfg")
  vars = {
    HOSTNAME = "${each.key}"
  }
}
data "template_file" "network_config" {
  template = file("files/network_config.cfg")
}

data "template_file" "user_data_ubuntu" {
  for_each = { for domain in local.domains_ubuntu : domain.name => domain }
  template = file("files/cloud_init.cfg")
  vars = {
    HOSTNAME = "${each.key}"
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each       = { for domain in local.domains_disks : domain.name => domain }
  depends_on     = [libvirt_pool.oracle]
  name           = "${each.key}"
  user_data      = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.oracle.name
}
#
resource "libvirt_pool" "oracle" {
  name = "oracle"
  type = "dir"
  path = "/opt/RAID10/cloud-init"
}

#resource "libvirt_cloudinit_disk" "commoninit_ubuntu" {
#  for_each   = { for domain in local.domains_ubuntu : domain.name => domain }
#  depends_on = [libvirt_pool.oracle]
#  name       = "${each.key}"
#  user_data  = data.template_file.user_data_ubuntu[each.key].rendered
#  pool       = libvirt_pool.oracle.name
#}
