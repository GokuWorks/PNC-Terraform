resource "helm_release" "authentik" {
  depends_on = [kubectl_manifest.cert_manager_issuer]
  name       = "authentik"
  namespace  = "authentik"
  create_namespace = true

  repository = "https://charts.goauthentik.io"
  chart      = "authentik"

  values = [
    <<EOF
global:
  namespaceOverride: authentik
  env:
    - name: AUTHENTIK_BOOTSTRAP_TOKEN
      value: "${var.authentik_token}"
    - name: AUTHENTIK_BOOTSTRAP_PASSWORD
      value: "${var.authentik_pass}"

authentik:
  log_level: info
  secret_key: "${var.auth_secret}"
  error_reporting:
    enabled: false
  postgresql:
    password: "${var.auth_pg_pass}"
    port: 5432
  email:
    port: 597
    use_tls: true

postgresql:
  enabled: true
  auth:
    password: "${var.auth_pg_pass}"

redis:
  enabled: true

server:
  ingress:
    enabled: true
    annotations:
      gethomepage.dev/enabled: "true"
      gethomepage.dev/name: "Authentik"
      gethomepage.dev/pod-selector: "app.kubernetes.io/name=authentik"
      gethomepage.dev/description: "A secure single-sign-on provider"
      gethomepage.dev/group: "Service"
      gethomepage.dev/icon: "authentik.png"
    ingressClassName: traefik
    https: false
    hosts:
      - "${var.authentik_fqdn}"
    tls:
      - secretName: authentik-certificate-secret

    EOF
  ]

  wait = true
  timeout = 600 # 10 minutes
}

resource "kubectl_manifest" "authentik_cert" {
  depends_on = [helm_release.authentik]
  yaml_body = <<YAML
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: authentik-ingressroute-certificate
  namespace: authentik
spec:
  issuerRef:
    name: cloudflare-clusterissuer
    kind: ClusterIssuer
  dnsNames:
    - "${var.authentik_fqdn}"
  secretName: authentik-certificate-secret

YAML
}
