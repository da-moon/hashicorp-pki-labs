provider "kubernetes" {
  config_context_cluster    = var.kubernetes_config_context_cluster
  config_path               = var.kubernetes_config_path
}

provider "kubernetes-alpha" {
  config_context_cluster    = var.kubernetes_config_context_cluster
  config_path               = var.kubernetes_config_path
}

provider "helm" {
  kubernetes {
    config_context_cluster  = var.kubernetes_config_context_cluster
    config_path             = var.kubernetes_config_path
  }
}
