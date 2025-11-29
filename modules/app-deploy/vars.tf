variable "kubeconfig_path" {
    type = string
}
variable "kube_vip" {
    type = string
}

# Application config vars
variable "argocd_fqdn" {
    type = string
}

variable "apps_user" {
    type = string
}

variable "apps_token" {
    type = string
}
