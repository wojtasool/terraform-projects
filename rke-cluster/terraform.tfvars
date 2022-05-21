rkeConfig = {
  upgrade_strategy = {
    drain                  = true
    max_unavailable_worker = "25%"
  }
}

hosts = [
  {
    hostname    = "os-argocd02.testnet.lab"
    ip          = "10.128.1.180"
    role        = ["controlplane", "etcd", "worker"]
    annotations = ""
    labels      = ""
  }
]

