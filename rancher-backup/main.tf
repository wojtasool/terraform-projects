resource "helm_release" "backup-crds" {
  name   = "backup-crds"
  chart  = "./chart-crds"
  atomic = true
}

resource "helm_release" "backup" {
  depends_on = [helm_release.backup-crds]
  name       = "backup-crds"
  chart      = "./chart"
  atomic     = true
}
