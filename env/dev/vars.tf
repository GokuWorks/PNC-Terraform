# Proxmox provider vars
variable "proxmox_endpoint" {
    type = string
}
variable "proxmox_username" {
    type = string
}
variable "proxmox_password" {
    type = string
    sensitive = true
}

# VM vars
variable "hostname" {
    type = list(string)
}
variable "node" {
    type = list(string)
}
variable "vm_id" {
    type = list(string)
}
variable "vm_cores" {
    type = list(string)
}
variable "vm_memory" {
    type = list(string)
}
variable "vm_ipv4" {
    type = list(string)
}
variable "gateway" {
    type = string
}
variable "vm_user" {
    type = string
}
variable "vm_pass" {
    type = string
}
variable "ssh_public_key" {
    type = list(string)
}
variable "vm_size" {
    type = list(string)
}

# k3s vars
variable "k3sup_version" {
    type = string
}
variable "k3s_version" {
    type = string
}
variable "kube_vip" {
    type = string
}
variable "kube_vip_range" {
    type = list(string)
}
variable "kube_fqdn" {
    type = string
}
variable "kubeconfig_path" {
    type = string
}
variable "ssh_private_key" {
    type = string
    sensitive = true
}

# Application config vars
variable "cloudflare_api_token" {
    type = string
    sensitive = true
}
variable "cloudflare_fqdn" {
    type = string
}
variable "cloudflare_email" {
    type = string
}

variable "traefik_dash_fqdn" {
    type = string
}

variable "authentik_fqdn" {
    type = string
}
variable "auth_secret" {
    type = string
} # openssl rand 40 | base64 -w 0
variable "auth_pg_pass" {
    type = string
} # openssl rand 40 | base64 -w 0
variable "authentik_token" {
    type = string
    sensitive = true
}
variable "authentik_pass" {
    type = string
    sensitive = true
}

variable "homepage_fqdn" {
    type = string
}

variable "vaultwarden_fqdn" {
    type = string
}
