resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  values = [
    <<EOF
crds:
  enabled: true
extraArgs:
  - --dns01-recursive-nameservers-only
  - --dns01-recursive-nameservers=1.1.1.1:53,1.0.0.1:53
    EOF
  ]

  wait = true
  timeout = 600 # 10 minutes
}

resource "kubectl_manifest" "cert_manager_token" {
  depends_on = [helm_release.cert_manager]
  yaml_body = <<YAML
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: cloudflare-api-token-secret
  namespace: cert-manager
data:
  api-token: ${base64encode(var.cloudflare_api_token)}

YAML
}

resource "kubectl_manifest" "cert_manager_issuer" {
  depends_on = [helm_release.cert_manager]
  yaml_body = <<YAML
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: cloudflare-clusterissuer
spec:
  acme:
    email: ${var.cloudflare_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cloudflare-clusterissuer-account-key
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token

YAML
}
