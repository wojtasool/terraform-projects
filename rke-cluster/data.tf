data "template_file" "inventory" {
  for_each = { for record in local.hosts : record.hostname => record }
  template = file("${path.module}/inventory.tpl")

  vars = {
    ip       = each.value.ip
    hostname = each.value.hostname
    selinux  = local.selinux
  }
}

resource "local_file" "inventory" {
  for_each = { for record in local.hosts : record.hostname => record }
  content  = data.template_file.inventory[each.value.hostname].rendered
  filename = "${each.value.hostname}.inventory.yaml"
}
