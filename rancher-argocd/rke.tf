resource "rke_cluster" "cluster" {
  depends_on            = [null_resource.provisioner]
  disable_port_check    = false
  ignore_docker_version = true
  kubernetes_version    = local.kubernets_version
  network {
    plugin = local.rke_network_plugin
  }
  dynamic nodes {
    for_each = local.hosts
    content {
      address           = nodes.value.ip
      internal_address  = nodes.value.ip
      user              = local.remote_user
      role              = nodes.value.role
      ssh_key           = file(local.ssh_key_path)
      node_name         = nodes.value.hostname
      hostname_override = nodes.value.hostname
    }
  }

  monitoring {
    provider = "none"
  }
  addon_job_timeout = 600

  authentication {
    strategy = "x509"
  }
}
resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = rke_cluster.cluster.kube_config_yaml
}

