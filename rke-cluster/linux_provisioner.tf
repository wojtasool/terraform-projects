resource "null_resource" "linux_provisioner_rke_node" {
  for_each = { for server in local.hosts : server.hostname => server }

  triggers = {
    ip       = each.value.ip
    playbook = "${sha1(file("${path.module}/playbooks/rke_nodes.yml"))}"
    role     = each.value.role[0]
  }

  connection {
    type        = "ssh"
    host        = self.triggers.ip
    user        = "root"
    private_key = file(local.ssh_key_path)
  }
  provisioner "remote-exec" {
    inline = [
      "echo ${join(" ", each.value.role)} > /tmp/roles"
    ]
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${local_file.inventory[each.value.hostname].filename} --private-key=${local.ssh_key_path} ${path.module}/playbooks/rke_nodes.yml -t provision"
  }
}
