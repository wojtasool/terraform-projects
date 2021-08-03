
locals {
  domains = [
    #    {
    #      name   = "k3s-master01"
    #      memory = "2048"
    #      cpu    = "2"
    #    },
    #    {
    #      name   = "k3s-master02"
    #      memory = "2048"
    #      cpu    = "2"
    #    },
    #    {
    #      name   = "k3s-master03"
    #      memory = "2048"
    #      cpu    = "2"
    #    },
    {
      name   = "gitlab01"
      memory = "12048"
      cpu    = "8"
    },
    {
      name   = "rancher-master01"
      memory = "2048"
      cpu    = "2"
    },
    {
      name   = "rancher-master02"
      memory = "2048"
      cpu    = "2"
    },
    {
      name   = "rancher-master03"
      memory = "2048"
      cpu    = "2"
    },
    {
      name   = "rancher-worker01"
      memory = "2048"
      cpu    = "2"
    },
    {
      name   = "rancher-worker02"
      memory = "2048"
      cpu    = "2"
    }
  ]
}


resource "libvirt_domain" "node" {
  for_each = { for domain in local.domains : domain.name => domain }
  name     = "${each.key}"
  memory   = (try("${each.value.memory}", 0) == 0) ? var.default_memory : "${each.value.memory}"
  vcpu     = (try("${each.value.cpu}", 0) == 0) ? var.default_cpu : "${each.value.cpu}"

  disk {
    volume_id = libvirt_volume.node_root_disk[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id
  network_interface {
    network_name   = "10.127.0.0"
    wait_for_lease = true
  }
}
