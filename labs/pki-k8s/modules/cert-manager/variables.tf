
variable "service_account_namespace" {
  description = "Kuberentes namespace used for cert-manager"
  default     = "cert-manager"
  type        = string
}
variable "application_namespace" {
  description = "Kuberentes application namespace"
  default     = "web-server"
  type        = string
}

variable "service_account_name" {
  description = "Kuberentes service account name (metadata)"
  default     = "cert-manager-service-account"
  type        = string
}
variable "cert_manager_version" {
  description = "cert-manager version"
  default     = "1.0.0"
  type        = string
}
# [ TODO ] read from output of PKI
variable "role_name" {
  description = "PKI Role Name"
  default     = "acme-dot-com"
  type        = string
}
variable "k8s_auth_mount" {
  description = "mount path for k8s auth method"
  default     = "minikube"
  type        = string
}
variable "pki_policy_name" {
  description = <<EOF
  Vault Policy name used with PKI engine to allow certificate generation
  EOF
  default     = "acme-dot-com"
  type        = string
}
