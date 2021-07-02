
#
# ──────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: S H A R E D   V A R I A B L E S : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────
#
variable "vault_addr" {}
variable "role_name" {
  description = "Role Name"
  default     = "acme-dot-com"
  type        = string
}
variable "kubernetes_config_path" {
  default     = "~/.kube/config"
  type        = string
}
variable "kubernetes_config_context_cluster" {
  default     = "minikube"
  type        = string
}
variable "kubernetes_host" {
  description = "Kuberentes host address"
  type        = string
}
#
# ────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: A P P L I C A T I O N   V A R I A B L E S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────
#
variable "application_k8s_namespace" {
  description = "Kuberentes namespace used with sample application"
  default     = "web-server"
  type        = string
}
variable "application_k8s_service_name" {
  description = "Application Service name"
  default     = "echo-server"
  type        = string
}
variable "application_k8s_ingress_service_port" {
  description = "Application Service Port"
  default     = "5678"
  type        = string
}
variable "application_k8s_ingress_secret_name" {
  default     = "echo-server-certificate"
  type        = string
  # sensitive   = true
}

#
# ──────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: K 8 S   M O D U L E   V A R I A B L E S : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────
#
variable "k8s_auth_path" {
  description = "path on vault to mount kubernetes auth"
  default     = "minikube"
  type        = string
}

variable "vault_k8s_sa_namespace" {
  description = "Kuberentes namespace used with Vault service account"
  default     = "default"
  type        = string
}
variable "vault_k8s_sa_name" {
  description = "Kuberentes service account name for Vault's k8s auth method (metadata)"
  default     = "vault-service-account"
  type        = string
}
variable "vault_k8s_rb_name" {
  description = "Kuberentes ClusterRoleBinding name for Vault's k8s auth method (metadata)"
  default     = "role-tokenreview-binding"
  type        = string
}
#
# ──────────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C E R T M A N A G E R   M O D U L E   V A R I A B L E S : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────
#


variable "cert_manager_k8s_namespace" {
  description = "Namespace for deploying cert-manager"
  default     = "cert-manager"
  type        = string
}

variable "cert_manager_k8s_sa_name" {
  description = "Kuberentes service account name (metadata)"
  default     = "cert-manager-service-account"
  type        = string
}
variable "cert_manager_version" {
  description = "cert-manager version"
  default     = "1.0.4"
  type        = string
}
#
# ──────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: P K I   M O D U L E   V A R I A B L E S : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────
#
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
  default     = "acme.local"
  type        = string
}
variable "subdomains" {
  description =<<EOF
  subdomains to create roles for cerificate generation.
  EOF
  type        = list(string)
  default     = [
    "us-west-1",
  ]
}
locals {
  applciation_host = "${var.subdomains[0]}.${var.root_domain}"
}
