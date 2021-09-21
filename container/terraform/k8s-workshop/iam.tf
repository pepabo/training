locals {
  issuer_host_path                = trim(local.issuer_url, "https://")
  provider_arn                    = "arn:aws:iam::${local.account_id}:oidc-provider/${local.issuer_host_path}"
  externaldns_service_account_arn = "system:serviceaccount:${local.externaldns_ns}:${local.externaldns_sa}"
  certmanager_service_account_arn = "system:serviceaccount:${local.certmanager_ns}:${local.certmanager_sa}"
}

data "aws_iam_policy_document" "oidc_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.issuer_host_path}:sub"
      values   = [local.externaldns_service_account_arn]
    }
  }
}

data "aws_iam_policy_document" "certmanager_oidc_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.issuer_host_path}:sub"
      values   = [local.certmanager_service_account_arn]
    }
  }
}

data "aws_iam_policy_document" "route53_access" {
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cert-manager" {
  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "route53_access" {
  name   = "training-external-dns-route53-access"
  path   = "/"
  policy = data.aws_iam_policy_document.route53_access.json
}

resource "aws_iam_role" "external_dns" {
  name               = "${module.training-cluster.cluster_id}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume.json
  path               = "/"
}

resource "aws_iam_role_policy_attachment" "route53_access" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.route53_access.arn
}

resource "aws_iam_policy" "certmanager_route53_access" {
  name   = "training-cert-manager-route53-access"
  path   = "/"
  policy = data.aws_iam_policy_document.cert-manager.json
}

resource "aws_iam_role" "cert_manager" {
  name               = "${module.training-cluster.cluster_id}-cert-manager"
  assume_role_policy = data.aws_iam_policy_document.certmanager_oidc_assume.json
  path               = "/"
}

resource "aws_iam_role_policy_attachment" "certmanager_route53_access" {
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.certmanager_route53_access.arn
}
