

variable "kubernetes_namespace" {
  type        = string
}
variable "secret_name" {
  type        = string
}
variable "role_name" {
  type        = string
}
variable "issuer_sign_path" {
  type        = string
}
variable "vault_addr" {
  type        = string
}
variable "root_domain" {
  type        = string
}
variable "application_host" {
  type        = string
}
variable "application_k8s_ingress_secret_name" {
  type        = string
}
variable "k8s_auth_mount" {
  type        = string
}
