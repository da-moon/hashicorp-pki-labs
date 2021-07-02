
variable "auth_mount_path" {
  description = "kubernetes auth method mount path"
  default     = "minikube"
  type        = string
}
variable "service_account_namespace" {
  description = "Kuberentes namespace used for deploying components"
  default     = "default"
  type        = string
}
variable "service_account_name" {
  description = "Kuberentes service account name (metadata)"
  default     = "vault-service-account"
  type        = string
}
variable "cluster_role_binding_name" {
  description = "Kuberentes ClusterRoleBinding name (metadata)"
  // default     = "role-tokenreview-binding"
  default     = "token-review-cluster-role-binding"
  type        = string
}
variable "kubernetes_host" {
  description = "Kuberentes host address"
  type        = string
}
