resource "rke_cluster" "rke-cluster" {
  depends_on            = [null_resource.linux_provisioner_rke_node]
  disable_port_check    = local.rkeSettings.disable_port_check
  ignore_docker_version = local.rkeSettings.ignore_docker_version
  network {
    plugin = local.rkeSettings.network_plugin
  }
  upgrade_strategy {
    drain                  = local.rkeSettings.upgrade_strategy.drain
    max_unavailable_worker = local.rkeSettings.upgrade_strategy.max_unavailable_worker
  }
  dynamic nodes {
    for_each = local.hosts
    content {
      address           = nodes.value.ip
      internal_address  = nodes.value.ip
      user              = local.remote_user
      role              = nodes.value.role
      ssh_key_path      = local.ssh_key_path
      node_name         = nodes.value.hostname
      hostname_override = nodes.value.hostname
    }
  }
  addon_job_timeout = 300
  authentication {
    strategy = "x509"
  }
  services {
    kubeproxy {
      extra_binds = [
        "/lib/modules:/lib/modules:ro"
      ]
    }
  }
}


resource "local_file" "kube_config_server_yaml" {
  filename = format("%s/%s", path.root, "kube_config_rancher_server.yaml")
  content  = rke_cluster.rke-cluster.kube_config_yaml
}
