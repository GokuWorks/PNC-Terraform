terraform {
    required_providers {
      proxmox = {
        source = "bpg/proxmox"
        version = "0.77.1"
      }
      null = {
        source  = "hashicorp/null"
        version = "~> 3.2"
      }
      local = {
        source  = "hashicorp/local"
        version = "~> 2.5"
      }
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

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = false
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

provider "kubectl" {
  config_path = var.kubeconfig_path
}
