terraform {
    required_providers {
      proxmox = {
        source = "bpg/proxmox"
      }
      null = {
        source  = "hashicorp/null"
      }
      local = {
        source  = "hashicorp/local"
      }
    }
}
