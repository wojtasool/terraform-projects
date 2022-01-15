resource "helm_release" "cert_manager" {
  #depends_on = [
  #  k8s_manifest.cert_manager_crds,
  #]

  repository       = "https://charts.jetstack.io"
  name             = "cert-manager"
  chart            = "cert-manager"
  version          = "v${local.cert_manager_version}"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}


resource "helm_release" "rancher_server" {
  repository       = "https://releases.rancher.com/server-charts/latest"
  name             = "rancher"
  chart            = "rancher"
  version          = local.rancher_version
  namespace        = "cattle-system"
  create_namespace = true

  set {
    name  = "hostname"
    value = local.rancher_server_dns
  }
  set {
    name  = "ingress.tls.source"
    value = "rancher"
  }
  set {
    name  = "bootstrapPassword"
    value = "rancher123"
  }
}
resource "helm_release" "argocd_server" {
  depends_on       = [helm_release.rancher_server]
  repository       = "./argo-helm/charts/"
  name             = "argocd"
  chart            = "argo-cd"
  create_namespace = true

  set {
    name  = "server.certificate.domain"
    value = local.argocd_server_dns
  }
  set {
    name  = "ingress.tls.source"
    value = "rancher"
  }
}

# Helm provider
provider "helm" {
  kubernetes {
    host = rke_cluster.cluster.api_server_url

    client_certificate     = rke_cluster.cluster.client_cert
    client_key             = rke_cluster.cluster.client_key
    cluster_ca_certificate = rke_cluster.cluster.ca_crt
  }
}

