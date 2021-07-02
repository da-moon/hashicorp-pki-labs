/* -------------------------------------------------------------------------- */
/*                             root ca pki engine                             */
/* -------------------------------------------------------------------------- */

resource "vault_mount" "pki_engine" {
  path                  = var.root_pki_path
  type                  = "pki"
  max_lease_ttl_seconds = var.root_ttl
}
resource "vault_pki_secret_backend_root_cert" "interal_root_cert" {
  depends_on = [
    vault_mount.pki_engine,
  ]
  backend            = vault_mount.pki_engine.path
  type               = "internal"
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = 4096
  common_name        = var.root_domain
  ttl                = var.root_ttl
  organization       = var.organization
  ou                    = terraform.workspace
}

resource "vault_pki_secret_backend_config_urls" "config_urls_root" {
  backend                 = vault_mount.pki_engine.path
  issuing_certificates    = [
      "${var.vault_domain_address}/v1/${vault_mount.pki_engine.path}/ca",
      "https://127.0.0.1/v1/${vault_mount.pki_engine.path}/ca"]
  crl_distribution_points = [
    "${var.vault_domain_address}/v1/${vault_mount.pki_engine.path}/crl",
     "https://127.0.0.1/v1/${vault_mount.pki_engine.path}/crl"]

}

/* -------------------------------------------------------------------------- */
/*                         intermediate ca pki engine                         */
/* -------------------------------------------------------------------------- */

/* ------------------ mount pki engine for intermediate ca ------------------ */

resource "vault_mount" "pki_engine_int" {
  path                  = var.int_pki_path
  type                  = "pki"
  max_lease_ttl_seconds = var.int_ttl
}
resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on            = [vault_mount.pki_engine_int]
  backend               = vault_mount.pki_engine_int.path
  common_name           = var.root_domain
  type                  = "internal"
  organization          = var.organization
  ou                    = terraform.workspace
}

/* ------------------ use root CA to sign intermediate Cert ----------------- */

resource "vault_pki_secret_backend_root_sign_intermediate" "root" {
  depends_on = [
    vault_pki_secret_backend_intermediate_cert_request.intermediate,
    vault_mount.pki_engine,
  ]
  backend     = vault_mount.pki_engine.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name = var.root_domain
  ttl         = var.int_ttl
  format      = "pem"
}

/* ------------ set the signed intermediate ca as intermediate ca ----------- */

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  depends_on = [
    vault_mount.pki_engine_int,
    vault_pki_secret_backend_root_sign_intermediate.root,
  ]
  backend  = vault_mount.pki_engine_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.root.certificate
}
resource "vault_pki_secret_backend_config_urls" "config_urls_int" {
  depends_on                = [
    vault_mount.pki_engine_int,
  ]
  backend                   = vault_mount.pki_engine_int.path
  issuing_certificates      = [
    "${var.vault_domain_address}/v1/${vault_mount.pki_engine_int.path}/ca",
    "https://127.0.0.1/v1/${vault_mount.pki_engine_int.path}/ca"]
  crl_distribution_points = [
    "${var.vault_domain_address}/v1/${vault_mount.pki_engine_int.path}/crl",
    "https://127.0.0.1/v1/${vault_mount.pki_engine_int.path}/crl"]
}

/* -------------------------------------------------------------------------- */
/*     creation of role and policy for generating self signed certificates    */
/* -------------------------------------------------------------------------- */

// -------------------------------------------------------------------------- //
// vault write pki_int/issue/acme-dot-com \
// common_name=foobar.us-west-1.acme.net \
// alt_names="us-west-1.acme.net"
// vault write pki_int/issue/acme-dot-com \
// common_name=foobar.us-west-1.acme.net \
// alt_names="us-west-1.acme.net"
// -------------------------------------------------------------------------- //
// curl -fSsl \
// --header "X-Vault-Token: ${VAULT_TOKEN}" \
// --request POST \
// --data "{\"common_name\": \"foobar.us-west-1.acme.net\"}" \
// "${VAULT_ADDR}/v1/pki_int/issue/acme-dot-com" | \
// jq -r .data.certificate | openssl x509 -text --
// -------------------------------------------------------------------------- //
resource "vault_pki_secret_backend_role" "this" {
  backend          = vault_mount.pki_engine_int.path
  name             = "acme-dot-com"
  ttl              = var.cert_ttl
  allow_bare_domains  = "true"
  # [ NOTE ] => setting this to true would allow glob patterns
  allow_any_name      = "false"
  allow_localhost     = "true"
  allow_subdomains    = "true"
  generate_lease      = "true"
  allow_glob_domains  = "false"
  allowed_domains  = local.allowed_domains
}
resource "vault_policy" "acme-dot-com" {
  name       = "acme-dot-com"
  policy = <<EOT
path "${vault_mount.pki_engine_int.path}/sign/${vault_pki_secret_backend_role.this.name}" {
  capabilities = ["read", "update", "list", "delete"]
}
path "${vault_mount.pki_engine_int.path}/issue/${vault_pki_secret_backend_role.this.name}" {
  capabilities = ["read", "update", "list", "delete"]
}

path "${vault_mount.pki_engine_int.path}/certs" {
  capabilities = ["list"]
}
# path "${vault_mount.pki_engine_int.path}/revoke" {
#   capabilities = ["create", "update"]
# }
# path "${vault_mount.pki_engine_int.path}/tidy" {
#   capabilities = ["create", "update"]
# }
EOT
}
