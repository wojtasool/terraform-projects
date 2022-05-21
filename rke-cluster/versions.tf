terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    rke = {
      source = "rancher/rke"
    }
    k8s = {
      source = "banzaicloud/k8s"
    }
  }
  required_version = ">= 0.15"
}
