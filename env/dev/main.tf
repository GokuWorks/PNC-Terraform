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

module "app-deploy" {
  source = "../../modules/app-deploy"

  depends_on = [module.cluster.cluster_ready]
  
  kubeconfig_path = var.kubeconfig_path # module.cluster.kubeconfig_path
  kube_vip = var.kube_vip

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_fqdn = var.cloudflare_fqdn
  cloudflare_email = var.cloudflare_email

  traefik_dash_fqdn = var.traefik_dash_fqdn

  authentik_fqdn = var.authentik_fqdn
  auth_secret = var.auth_secret # openssl rand 40 | base64 -w 0
  auth_pg_pass = var.auth_pg_pass # openssl rand 40 | base64 -w 0

  homepage_fqdn = var.homepage_fqdn

  vaultwarden_fqdn = var.vaultwarden_fqdn
}

# module "app-config" {
#   source = "../../modules/app-config"  
# }
