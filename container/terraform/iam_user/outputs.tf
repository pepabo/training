output "iam_users" {
  value = tomap({
    for i, v in values(module.iam-user)[*] : "${v.iam_user_name}" => tomap({
      "ACCESS_KEY"        = v.iam_access_key_id,
      "SECRET_ACCESS_KEY" = v.keybase_secret_key_pgp_message
    })
  })
}
