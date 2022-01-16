
locals {
  default_boot_disk = var.default_os_disk
  default_disk_pool = "RAID10"
  domains_disks     = jsondecode(file("./definitions.json"))
  domains = [
    {
      name               = "os-cka01.testnet.lab"
      memory             = "4096"
      cpu                = "2"
      root_disk_pool     = "FAST"
      root_disk_template = "ubuntu-cka-template"
    },
    {
      name               = "os-cka02.testnet.lab"
      memory             = "4096"
      cpu                = "2"
      root_disk_pool     = "FAST"
      root_disk_template = "ubuntu-cka-template"
    },
    {
      name               = "os-cka03.testnet.lab"
      memory             = "4096"
      cpu                = "2"
      root_disk_pool     = "FAST"
      root_disk_template = "ubuntu-cka-template"
    },
    #    {
    #      name               = "os-gitlab01.testnet.lab"
    #      memory             = "12048"
    #      cpu                = "8"
    #      root_disk_pool     = "FAST"
    #      root_disk_template = "template"
    #      root_disk_size     = "30"
    #      additional_disks = [
    #        {
    #          name  = "data",
    #          label = "gitlab-data"
    #          size  = "20"
    #          pool  = "FAST"
    #        },
    #        {
    #          name  = "gitaly",
    #          label = "gitaly-data"
    #          size  = "10"
    #        }
    #      ]
    #    },
    #    {
    #      name   = "os-jenkins01.testnet.lab"
    #      memory = "8192"
    #      cpu    = "4"
    #      additional_disks = [
    #        {
    #          name  = "data",
    #          label = "jenkins-data"
    #          size  = "50"
    #        }
    #      ]
    #    },
    #    {
    #      name   = "os-minio01.testnet.lab"
    #      memory = "6192"
    #      cpu    = "4"
    #      additional_disks = [
    #        {
    #          name = "data",
    #          size = "20"
    #        }
    #      ]
    #    },
    #    {
    #      name   = "os-nexus01.testnet.lab"
    #      memory = "12048"
    #      cpu    = "8"
    #    },
    #    {
    #      name   = "os-kubemaster01.testnet.lab"
    #      memory = "4096"
    #      cpu    = "4"
    #    },
    #    {
    #      name   = "os-kubeworker01.testnet.lab"
    #      memory = "8192"
    #      cpu    = "4"
    #    },
    #    {
    #      name   = "os-kubeworker02.testnet.lab"
    #      memory = "8192"
    #      cpu    = "4"
    #    },
    #    {
    #      name   = "os-kubeworker03.testnet.lab"
    #      memory = "8192"
    #      cpu    = "4"
    #    },
    #    {
    #      name   = "os-ansible01.testnet.lab"
    #      memory = "4096"
    #      cpu    = "4"
    #    },
    {
      name               = "os-argocd01.testnet.lab"
      memory             = "8192"
      cpu                = "6"
      root_disk_pool     = "FAST"
      root_disk_template = "template"
      additional_disks = [
        {
          name = "data",
          size = "20"
        }
      ]
    },
    #    {
    #      name   = "os-harbor01.testnet.lab"
    #      memory = "8192"
    #      cpu    = "4"
    #    },
    #    {
    #      name   = "os-runner01.testnet.lab"
    #      memory = "8192"
    #      cpu    = "6"
    #    },
    #    {
    #      name   = "os-runner02.testnet.lab"
    #      memory = "8192"
    #      cpu    = "6"
    #    },
    #    {
    #      name   = "os-runner03.testnet.lab"
    #      memory = "8192"
    #      cpu    = "6"
    #    }
  ]
}



resource "libvirt_domain" "node" {
  for_each = { for domain in local.domains_disks : domain.name => domain }
  name     = "${each.key}"
  memory   = (try("${each.value.memory}", 0) == 0) ? var.default_memory : "${each.value.memory}"
  #memory  = (try(local.domains[each.key].memory, 0) == 0) ? var.default_memory : "${local.domains[each.key].memory}"
  vcpu    = (try("${each.value.cpu}", 0) == 0) ? var.default_cpu : "${each.value.cpu}"
  running = false

  disk {
    volume_id = "${each.value.OSDisk}" ##libvirt_volume.node_root_disk[each.key].id
  }
  dynamic disk {
    #for_each = [for k, v in each.value.additional_disks[0] : k]
    for_each = [for disk in each.value.additional_disks[0] : disk]
    content {
      volume_id = "${disk.value.name}"
    }
  }

  cpu {
    mode = "host-model"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id
  network_interface {
    network_name   = "10.128.0.0"
    wait_for_lease = true
  }
  lifecycle {
    ignore_changes = [
      network_interface[0].hostname,
      network_interface[0].addresses[0],
      cpu,
      running
    ]
  }
}
