resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    <<EOF
namespaceOverride: "argocd"
global:
  domain: "${var.argocd_fqdn}"

redis-ha:
  enabled: true

controller:
  replicas: 1

server:
  autoscaling:
    enabled: true
    minReplicas: 2
  ingress:
      enabled: true
      labels: {}
      annotations: {}
      ingressClassName: "traefik"

      ## TLS certificate will be retrieved from a TLS secret `argocd-server-tls`
      tls: true

repoServer:
  autoscaling:
    enabled: true
    minReplicas: 2

applicationSet:
  replicas: 2

configs:
  params:
    server.insecure: true # Fixes traefik ingress
  repositories:
    pnc-repo:
      url: https://github.com/GokuWorks/PNC-Apps.git
      name: PNC-Apps
      type: git
      username: "${var.apps_user}"
      password: "${var.apps_token}"
    EOF
  ]

  wait = true
  timeout = 600 # 10 minutes
}

resource "helm_release" "argocd-apps" {
  name       = "argocd-apps"
  namespace  = "argocd"
  create_namespace = false

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"

  values = [
    <<EOF
applications:
 default:
   namespace: argocd
   finalizers:
   - resources-finalizer.argocd.argoproj.io
   project: default
   source:
     repoURL: https://github.com/GokuWorks/PNC-Apps.git
     targetRevision: HEAD
     path: env/dev/apps
   destination:
     server: https://kubernetes.default.svc
     namespace: default
   syncPolicy:
     automated:
       prune: true
       selfHeal: true
    EOF
  ]

  wait = true
  timeout = 600 # 10 minutes
}

resource "kubectl_manifest" "argocd_cert" {
  depends_on = [helm_release.argocd]
  yaml_body = <<YAML
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-ingress-certificate
  namespace: argocd
spec:
  issuerRef:
    name: cloudflare-clusterissuer
    kind: ClusterIssuer
  dnsNames:
    - "${var.argocd_fqdn}"
  secretName: argocd-server-tls

YAML
}