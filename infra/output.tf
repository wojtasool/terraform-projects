#output "nodes" {
#  value = tomap({
#    for node, bd in libvirt_domain.node : node => bd.network_interface.0.addresses[0]
#  })
#}
