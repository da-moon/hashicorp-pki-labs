
variable "root_ttl" {
  description = "ttl and max ttl of root ca. Defaults to 10 years"
  default     = "315360000"
  type        = string
}
variable "int_ttl" {
  description = "ttl and max ttl of intermediate ca. Defaults to 5 years"
  default     = "157680000"
  type        = string
}
variable "cert_ttl" {
  description = "default ttl of generated certificates. Defaults to 30 days"
  default     = 2592000
  type        = number
}
variable "organization" {
  description = "certificate organization"
  default     = "acme"
  type        = string
}
variable "vault_domain_address" {
  description = "vault domain address"
  default     = "https://primary.dev.vault.tools.gcp.acme.net"
  type        = string
}
variable "root_pki_path" {
  description = "root pki engine mount path"
  default     = "pki"
  type        = string
}
variable "int_pki_path" {
  description = "intermediate pki engine mount path"
  default     = "pki_int"
  type        = string
}
variable "root_domain" {
  description = "common name of root ca"
  default     = "acme.com"
  type        = string
}
variable "subdomains" {
  description =<<EOF
  subdomains to create roles for cerificate generation.
  EOF
  type        = list(string)
  default     = [
    // customer facing
    "us-west-1",
    "us-east-1",
    "apac-southeast-1",
    "eu-central",
  ]
}
variable "role_name" {
  description = "PKI Role Name"
  default     = "acme-dot-com"
  type        = string
}
locals {
    allowed_domains = formatlist("%s.%s", var.subdomains,var.root_domain)
}
