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
    }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = false
}
