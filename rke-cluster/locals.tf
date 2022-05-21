locals {
  kubernets_version  = var.kubernetesVersion
  ssh_key_path       = var.sshKeyPath
  selinux            = "disabled"
  rke_network_plugin = var.rkeNetworkPlugin
  docker_directory   = "/opt/docker"
  remote_user        = var.remoteUser
  hosts              = var.hosts
  rkeSettings        = merge(var.rkeConfigDefaults, var.rkeConfig)
}
