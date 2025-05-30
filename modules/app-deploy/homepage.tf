resource "helm_release" "homepage" {
  depends_on = [kubectl_manifest.cert_manager_issuer]
  name       = "homepage"
  namespace  = "default"
  create_namespace = false

  repository = "https://jameswynn.github.io/helm-charts"
  chart      = "homepage" #"./charts/homepage"

  values = [
    <<EOF
env:
  - name: HOMEPAGE_ALLOWED_HOSTS
    value: ${var.homepage_fqdn}

enableRbac: true
serviceAccount:
  name: "homepage-rbac"
  create: true

config:
  bookmarks:
    - Developer:
        - Github:
            - abbr: GH
              icon: github.svg
              href: https://github.com/

  services:
    - Applications:
        - Test:
            href: http://localhost/
            description: Homepage test

    - Management:
        - Thing:
            href: http://localhost/
            description: Homepage is the best

    - Service:
        - Other Thing:
            href: http://localhost/
            description: Homepage baba

  widgets:
    - kubernetes:
        cluster:
          show: true
          cpu: true
          memory: true
          showLabel: true
          label: "cluster"
        nodes:
          show: true
          cpu: true
          memory: true
          showLabel: true
    - search:
        provider: duckduckgo
        target: _blank
  kubernetes:
    mode: cluster
    ingress: true
    traefik: true
  settingsString: |
    title: Homepage
    headerStyle: boxed
    layout:
      Applications:
      Management:
      Service:
ingress:
  main:
    enabled: true
    annotations:
      gethomepage.dev/enabled: "true"
      gethomepage.dev/name: "Homepage"
      gethomepage.dev/description: "A modern, secure, highly customizable application dashboard."
      gethomepage.dev/group: "Service"
      gethomepage.dev/icon: "homepage.png"
    ingressClassName: "traefik"
    hosts:
      - host: "${var.homepage_fqdn}"
        paths:
          - path: /
            pathType: Prefix 
    tls:
      - secretName: homepage-certificate-secret
        hosts:
          - "${var.homepage_fqdn}"

    EOF
  ]

  wait = true
  timeout = 600 # 10 minutes
  atomic = true
  force_update = true
}

resource "kubectl_manifest" "homepage_cert" {
  depends_on = [helm_release.homepage]
  yaml_body = <<YAML
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: homepage-ingressroute-certificate
  namespace: default
spec:
  secretName: homepage-certificate-secret
  issuerRef:
    name: cloudflare-clusterissuer
    kind: ClusterIssuer
  dnsNames:
    - "${var.homepage_fqdn}"

YAML
}
