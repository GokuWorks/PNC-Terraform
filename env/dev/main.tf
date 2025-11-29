module "cluster" {
  source = "../../modules/cluster"

  proxmox_username = var.proxmox_username
  proxmox_password = var.proxmox_password
  proxmox_endpoint = var.proxmox_endpoint

  hostname = var.hostname
  node = var.node
  vm_id = var.vm_id
  vm_cores = var.vm_cores
  vm_memory = var.vm_memory
  vm_ipv4 = var.vm_ipv4
  gateway = var.gateway
  vm_user = var.vm_user
  vm_pass = var.vm_pass
  ssh_public_key = var.ssh_public_key
  vm_size = var.vm_size

  k3sup_version = var.k3sup_version
  k3s_version = var.k3s_version
  kubeconfig_path = var.kubeconfig_path # Dont use paths with ~
  kube_vip = var.kube_vip
  kube_vip_range = var.kube_vip_range
  kube_fqdn = var.kube_fqdn
  ssh_private_key = var.ssh_private_key
}
