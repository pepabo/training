provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.training-cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.training-cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.training-cluster.token
  }
}

resource "helm_release" "sealed-secrets" {
  name       = "sealed-secrets"
  chart      = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  version    = "1.16.1"
  namespace  = "kube-system"
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "1.4.1"
  namespace        = "cert-manager"
  create_namespace = true

  values = [<<EOF
installCRDs: true
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.cert_manager.arn}
securityContext:
  enabled: true
  fsGroup: 1001
EOF
  ]
}

resource "helm_release" "external-dns" {
  name             = "external-dns"
  chart            = "external-dns"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = "5.2.1"
  namespace        = local.externaldns_ns
  create_namespace = true

  values = [<<EOF
provider: aws
policy: upsert-only
registry: txt
txtOwnerId: training
sources:
  - ingress  
domainFilters:
  - pepalab.com
serviceAccount:
  name: ${local.externaldns_sa}
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.external_dns.arn}
EOF
  ]
}

resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  chart            = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  version          = "3.34.0"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [<<EOF
controller:
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
defaultBackend:
  enabled: true
EOF
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "3.10.0"
  namespace        = "argocd"
  create_namespace = true

  values = [<<EOF
server:
  rbacConfig:
    policy.default: role:admin
  extraArgs:
    - --insecure
  config:
    url: https://${var.argocd_console_uri}
    dex.config: |
      connectors:
        - type: github
          id: pepabo-github
          name: Pepabo GitHub
          config:
            hostName: ${var.argocd_collectors_hostname}
            clientID: ${var.argocd_collectors_clientid}
            clientSecret: ${var.argocd_collectors_clientsecret}
            orgs:
            - name: ${var.argocd_collectors_org}
    admin.enabled: "false"
  ingress:
    enabled: true
    tls:
      - hosts:
        - ${var.argocd_console_uri}
        secretName: cert-argocd
    hosts:
      - ${var.argocd_console_uri}
EOF
  ]
}
