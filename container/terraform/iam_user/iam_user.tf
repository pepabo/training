module "iam-user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "4.2.0"

  for_each = toset(var.users)

  name                          = each.key
  create_iam_user_login_profile = false
  password_reset_required       = false
  pgp_key                       = var.gpg_public_key
}

module "iam_iam-group-with-policies" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "4.2.0"

  name                              = "training"
  custom_group_policy_arns          = [aws_iam_policy.training.arn]
  group_users                       = values(module.iam-user)[*].iam_user_name
  attach_iam_self_management_policy = false
}

module "iam_iam-assumable-roles-with-saml" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles-with-saml"
  version = "4.2.0"

  create_poweruser_role      = true
  poweruser_role_name        = "onelogin-training"
  poweruser_role_policy_arns = [aws_iam_policy.training.arn]
  provider_id                = "arn:aws:iam::${data.aws_caller_identity.self.account_id}:saml-provider/onelogin-training"
}