locals {
  kubernets_version    = "v1.20.4-rancher1-1"
  ssh_key_path         = "/opt/GIT/os/BASE_LAN/centos7/provisioners/hostkey"
  selinux              = "disabled"
  rke_network_plugin   = "canal"
  docker_directory     = "/opt/docker"
  cert_manager_version = "1.5.0"
  remote_user          = "cloud"
  rancher_version      = "2.6.3"
  rancher_server_dns   = "rancher.10.128.1.243.nip.io"
  argocd_server_dns    = "argocd.10.128.1.243.nip.io"
  hosts = [
    {
      hostname    = "os-argo01.testnet.lab"
      ip          = "10.128.1.243"
      role        = ["controlplane", "etcd", "worker"]
      annotations = ""
      labels      = ""
    }
  ]
}
