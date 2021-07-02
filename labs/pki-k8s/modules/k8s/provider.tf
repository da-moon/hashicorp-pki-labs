// variable "kubernetes_config_path" {
//   default     = "~/.kube/config"
//   type        = string
// }
// variable "kubernetes_config_context_cluster" {
//   default     = "minikube"
//   type        = string
// }
// provider "kubernetes" {
//   config_context_cluster    = var.kubernetes_config_context_cluster
//   config_path               = var.kubernetes_config_path
// }
// provider "helm" {
//   kubernetes {
//     config_context_cluster  = var.kubernetes_config_context_cluster
//     config_path             = var.kubernetes_config_path
//   }
// }
