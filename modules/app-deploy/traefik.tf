resource "helm_release" "traefik" {
  depends_on = [kubectl_manifest.cert_manager_issuer]
  name       = "traefik"
  namespace  = "traefik"
  create_namespace = true

  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  values = [
    <<EOF
ports:
  web:
    redirections:
      entryPoint:
        to: websecure
        scheme: https
        permanent: true
service:
  externalIPs:
    - ${var.kube_vip}
deployment:
  replicas: null
resources:
  requests:
    cpu: "100m"
    memory: "50Mi"
  limits:
    cpu: "300m"
    memory: "150Mi"
autoscaling:
  enabled: true
  maxReplicas: 2
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
    EOF
  ]

  wait = true
  timeout = 600 # 10 minutes
}

resource "kubectl_manifest" "traefik_cert" {
  depends_on = [helm_release.traefik]
  yaml_body = <<YAML
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: traefik-dash-ingressroute-certificate
  namespace: traefik
spec:
  issuerRef:
    name: cloudflare-clusterissuer
    kind: ClusterIssuer
  dnsNames:
    - "${var.traefik_dash_fqdn}"
  secretName: traefik-certificate-secret

YAML
}

resource "kubectl_manifest" "traefik_ingress" {
  depends_on = [kubectl_manifest.traefik_cert]
  yaml_body = <<YAML
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dash-ingressroute
  namespace: traefik
  annotations:
    gethomepage.dev/href: "https://${var.traefik_dash_fqdn}"
    gethomepage.dev/enabled: "true"
    gethomepage.dev/description: Traefik Dashboard
    gethomepage.dev/group: Management
    gethomepage.dev/icon: traefik.svg
    gethomepage.dev/name: Traefik
    gethomepage.dev/pod-selector: "app.kubernetes.io/name=traefik"
    gethomepage.dev/widget.type: "traefik"
    gethomepage.dev/widget.url: "https://${var.traefik_dash_fqdn}"
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`${var.traefik_dash_fqdn}`)
      kind: Rule
      services:
        - kind: TraefikService
          name: api@internal
      #middlewares:
      #  - name: traefik-dash-middleware
  tls:
    secretName: traefik-certificate-secret

YAML
}
