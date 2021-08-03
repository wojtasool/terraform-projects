data "template_file" "user_data" {
  template = file("files/cloud_init.cfg")
}


resource "libvirt_cloudinit_disk" "commoninit" {
  depends_on = [libvirt_pool.oracle]
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  pool           = libvirt_pool.oracle.name
}

resource "libvirt_pool" "oracle" {
  name = "oracle"
  type = "dir"
  path = "/opt/RAID10/cloud-init"
}
