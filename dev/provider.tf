terraform {
    required_version = ">= 1.11.3"

    required_providers {
      proxmox = {
        source  = "Telmate/proxmox"
        version = "3.0.1-rc8"       
      }
    }
}

provider "proxmox" {
  pm_user = var.proxuser
  pm_password = var.proxpass
  pm_api_url = var.endpoint
}
