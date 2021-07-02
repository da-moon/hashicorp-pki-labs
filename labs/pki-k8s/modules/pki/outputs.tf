output "allowed_common_names" {
  value = local.allowed_domains
}
output "policy_name" {
  value = vault_policy.this.name
}

output "int_pki_sign_path" {
  value = "${vault_mount.pki_engine_int.path}/sign/${vault_pki_secret_backend_role.this.name}"
}
