variable "kubeconfig_path" {
    type = string
}
variable "kube_vip" {
    type = string
}

# Application config vars
variable "cloudflare_api_token" {
    type = string
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

variable "homepage_fqdn" {
    type = string
}

variable "vaultwarden_fqdn" {
    type = string
}
