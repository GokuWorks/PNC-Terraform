# Proxmox provider vars
variable "proxmox_endpoint" {
    type = string
}
variable "proxmox_username" {
    type = string
}
variable "proxmox_password" {
    type = string
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
