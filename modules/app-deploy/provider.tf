terraform {
    required_providers {
      helm = {
        source  = "hashicorp/helm"
        version = "3.0.0-pre2"
      }
      kubectl = {
        source  = "gavinbunney/kubectl"
        version = ">= 1.7.0"
      }
    }
}
