variable "hostname1" {
  type = string
}

variable "hostname2" {
  type = string
}

variable "hostname3" {
  type = string
}

variable "boxuser" {
  type = string
}

variable "boxpassword" {
  type = string
}

variable "ssh_public_keys" {
  type = string
}

resource "proxmox_vm_qemu" "box1" {
  target_node = "pve"
  name = var.hostname1
  clone_id = 2000
  os_type = "cloud-init"
  ciuser = var.boxuser
  cipassword = var.boxpassword
  sockets = 1
  cores = 8
  memory = 12288
  sshkeys = var.ssh_public_keys
  vmid = 201
  ipconfig0 = "ip=10.0.16.1/16,gw=10.0.0.1"
  skip_ipv6 = true
  agent = 1
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  full_clone = true
  vm_state = "stopped"
  
  disks {
    ide {
      ide3 {
        cloudinit {
            storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size = 40
          emulatessd = true
          iothread = true
          replicate = false
        }
      }
    }
  }

  serial {
    id   = 0
    type = "socket"
  }

  network {
    id = 0
    model = "virtio"
    bridge = "vmbr0"
  }
}

resource "proxmox_vm_qemu" "box2" {
  target_node = "pve"
  name = var.hostname2
  clone_id = 2000
  os_type = "cloud-init"
  ciuser = var.boxuser
  cipassword = var.boxpassword
  sockets = 1
  cores = 3
  memory = 12288
  sshkeys = var.ssh_public_keys
  vmid = 202
  ipconfig0 = "ip=10.0.16.2/16,gw=10.0.0.1"
  skip_ipv6 = true
  agent = 1
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  full_clone = true
  vm_state = "stopped"
  
  disks {
    ide {
      ide3 {
        cloudinit {
            storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size = 40
          emulatessd = true
          iothread = true
          replicate = false
        }
      }
    }
  }

  serial {
    id   = 0
    type = "socket"
  }

  network {
    id = 0
    model = "virtio"
    bridge = "vmbr0"
  }
}

resource "proxmox_vm_qemu" "box3" {
  target_node = "pve"
  name = var.hostname3
  clone_id = 2000
  os_type = "cloud-init"
  ciuser = var.boxuser
  cipassword = var.boxpassword
  sockets = 1
  cores = 3
  memory = 6144
  sshkeys = var.ssh_public_keys
  vmid = 203
  ipconfig0 = "ip=10.0.16.3/16,gw=10.0.0.1"
  skip_ipv6 = true
  agent = 1
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  full_clone = true
  vm_state = "stopped"
  
  disks {
    ide {
      ide3 {
        cloudinit {
            storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size = 40
          emulatessd = true
          iothread = true
          replicate = false
        }
      }
    }
  }

  serial {
    id   = 0
    type = "socket"
  }

  network {
    id = 0
    model = "virtio"
    bridge = "vmbr0"
  }
}
