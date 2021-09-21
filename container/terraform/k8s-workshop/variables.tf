data "aws_caller_identity" "current" {}

locals {
  issuer_url           = module.training-cluster.cluster_oidc_issuer_url
  account_id           = data.aws_caller_identity.current.account_id
  externaldns_ns       = "external-dns"
  externaldns_sa       = "external-dns"
  externaldns_iam_role = "training-external-dns"
  certmanager_ns       = "cert-manager"
  certmanager_sa       = "cert-manager"
}

variable "argocd_console_uri" {
  type = string
}

variable "argocd_collectors_hostname" {
  type = string
}

variable "argocd_collectors_clientid" {
  type = string
}

variable "argocd_collectors_clientsecret" {
  type = string
}

variable "argocd_collectors_org" {
  type = string
}
