output "secret_name" {
    value=kubernetes_service_account.this.default_secret_name
}
output "role_name" {
    value=vault_kubernetes_auth_backend_role.this.role_name
}
