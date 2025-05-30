resource "helm_release" "vaultwarden" {
  depends_on = [kubectl_manifest.cert_manager_issuer]
  name       = "vaultwarden"
  namespace  = "default"
  create_namespace = false

  repository = "https://charts.pascaliske.dev"
  chart      = "vaultwarden"

  values = [
    <<EOF
ingressRoute:
  create: true
  entryPoints:
    - websecure
  rule: "Host(`${var.vaultwarden_fqdn}`)"
  middlewares: []
  tlsSecretName: vaultwarden-certificate-secret
  annotations:
    gethomepage.dev/href: "https://${var.vaultwarden_fqdn}"
    gethomepage.dev/enabled: "true"
    gethomepage.dev/description: Vaultwarden Dashboard
    gethomepage.dev/group: Services
    gethomepage.dev/icon: vaultwarden.svg
    gethomepage.dev/pod-selector: "app.kubernetes.io/name=vaultwarden"
    gethomepage.dev/name: Vaultwarden
    EOF
  ]

  wait = true
  timeout = 600 # 10 minutes
}

resource "kubectl_manifest" "vaultwarden_cert" {
  depends_on = [helm_release.vaultwarden]
  yaml_body = <<YAML
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: vaultwarden-ingressroute-certificate
  namespace: default
spec:
  issuerRef:
    name: cloudflare-clusterissuer
    kind: ClusterIssuer
  dnsNames:
    - "${var.vaultwarden_fqdn}"
  secretName: vaultwarden-certificate-secret

YAML
}
