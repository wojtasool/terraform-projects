locals {
  kubeconfig_raw = yamldecode(rke_cluster.rke-cluster.kube_config_yaml)
  kubernetes = {
    host                   = local.kubeconfig_raw["clusters"][0]["cluster"]["server"]
    client_certificate     = rke_cluster.rke-cluster.client_cert
    client_key             = rke_cluster.rke-cluster.client_key
    cluster_ca_certificate = rke_cluster.rke-cluster.ca_crt
  }
}

provider "kubectl" {
  host                   = local.kubernetes.host
  client_key             = local.kubernetes.client_key
  client_certificate     = local.kubernetes.client_certificate
  cluster_ca_certificate = local.kubernetes.cluster_ca_certificate
  load_config_file       = false
  insecure               = false
}




#locals {
#  kubeconfig_raw = yamldecode(rke_cluster.rancher-cluster.kube_config_yaml)
#  kubernetes = {
#    host                   = local.kubeconfig_raw["clusters"][0]["cluster"]["server"]
#    client_certificate     = rke_cluster.rancher-cluster.client_cert
#    client_key             = rke_cluster.rancher-cluster.client_key
#    cluster_ca_certificate = rke_cluster.rancher-cluster.ca_crt
#  }
#}
#
#
#provider "kubectl" {
#  host                   = local.kubernetes_rancher2_cluster.host
#  cluster_ca_certificate = local.kubernetes_rancher2_cluster.cluster_ca_certificate
#  load_config_file       = false
#  insecure               = true
#}
#
#provider "k8s" {
#  alias = "custom"
#  host  = local.kubernetes_rancher2_cluster.host
#
#  load_config_file       = false
#  cluster_ca_certificate = local.kubernetes_rancher2_cluster.cluster_ca_certificate
#}
#
#
#provider "k8s" {
#  host = local.kubernetes.host
#
#  load_config_file       = false
#  client_certificate     = local.kubernetes.client_certificate
#  client_key             = local.kubernetes.client_key
#  cluster_ca_certificate = local.kubernetes.cluster_ca_certificate
#}
#
## Kubernetes provider
#provider "kubernetes" {
#  alias = "rancher_cluster"
#  #host               = libvirt_domain.haproxy-domain.network_interface.0.addresses[0]
#  host               = local.kubernetes.host
#  client_certificate = rke_cluster.rancher-cluster.client_cert
#  client_key         = rke_cluster.rancher-cluster.client_key
#  insecure           = true
#}
#
## Helm provider
#provider "helm" {
#  kubernetes {
#    host = local.kubernetes.host
#    #    host               = format("%s%s", libvirt_domain.haproxy-domain.network_interface.0.addresses[0], ".nip.io")
#    client_certificate = rke_cluster.rancher-cluster.client_cert
#    client_key         = rke_cluster.rancher-cluster.client_key
#    #cluster_ca_certificate = rke_cluster.rancher_cluster.ca_crt
#    insecure = true
#  }
#}
