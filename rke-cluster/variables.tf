variable "kubernetesVersion" {
  default = "v1.21.7-rancher1-1"
  type    = string
}
variable "sshKeyPath" {
  type    = string
  default = ""
}
variable "rkeNetworkPlugin" {
  type    = string
  default = "canal"
}
variable "remoteUser" {
  type    = string
  default = ""
}
variable "rkeConfig" {
  description = "rkeConfig to apply"
}
variable "rkeConfigDefaults" {
  type = object({
    network_plugin        = string
    disable_port_check    = bool
    ignore_docker_version = bool
    upgrade_strategy = object({
      drain                        = bool
      max_unavailable_worker       = string
      max_unavailable_controlplane = string
      drain_input = object({
        ignore_daemon_sets = bool
        delete_local_data  = bool
      })
    })
  })
  default = {
    network_plugin        = "canal"
    disable_port_check    = true
    ignore_docker_version = true
    upgrade_strategy = {
      drain                        = true
      max_unavailable_worker       = "35%"
      max_unavailable_controlplane = "35%"
      drain_input = {
        ignore_daemon_sets = true
        delete_local_data  = true
      }
    }
  }
}
variable "hosts" {
  type = list
  default = [
    {
      hostname    = ""
      ip          = ""
      role        = ""
      annotations = ""
      labels      = ""
    }
  ]
}
