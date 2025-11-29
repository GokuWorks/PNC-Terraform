resource "proxmox_virtual_environment_download_file" "cloudimg" {
  count = length(var.node)
  content_type = "iso"
  datastore_id = "local"
  node_name = var.node[count.index]
  url = "https://cloud-images.ubuntu.com/releases/questing/release/ubuntu-25.10-server-cloudimg-amd64.img" # "https://cloud-images.ubuntu.com/releases/plucky/release/ubuntu-25.04-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_vm" "vm" {
  count = length(var.hostname)
  name = var.hostname[count.index]
  tags = ["terraform", "k3s"]
  description = "Managed by Terraform"

  node_name = var.node[count.index]
  vm_id = var.vm_id[count.index]

  agent {
    enabled = false
  }

  stop_on_destroy = true
  
  cpu {
    cores = var.vm_cores[count.index]
    type = "host"
  }

  memory {
    dedicated = var.vm_memory[count.index]
  }

  initialization {
    user_account {
      username = var.vm_user
      password = var.vm_pass
      keys = var.ssh_public_key
    }

    ip_config {
      ipv4 {
        address = var.vm_ipv4[count.index]
        gateway = var.gateway
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    file_id = proxmox_virtual_environment_download_file.cloudimg[count.index].id
    interface = "virtio0"
    iothread = true
    discard = "on"
    size = var.vm_size[count.index]
  }

  depends_on = [
    proxmox_virtual_environment_download_file.cloudimg
  ]
}
