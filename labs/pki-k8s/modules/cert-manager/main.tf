#
# ────────────────────────────────────────────────────────────── I ──────────
#   :::::: C E R T M A N A G E R : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────
#

resource "kubernetes_service_account" "this" {
  metadata {
    // k8s-sa : cert-manager
    name      = var.service_account_name
    // sl : deployed in certmanager namespace
    // k8s-ns : web-server
    namespace = var.application_namespace
  }
  automount_service_account_token = true
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = var.k8s_auth_mount
  role_name                        = var.role_name
  bound_service_account_names      = [kubernetes_service_account.this.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_service_account.this.metadata[0].namespace]
  token_policies                   = [
    var.pki_policy_name
  ]
  token_ttl                        = 86400
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.service_account_namespace

    labels = {
      name = var.service_account_namespace
    }
  }
}
resource "helm_release" "this" {
  namespace  = kubernetes_namespace.this.metadata[0].name
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_version
  set {
    name  = "installCRDs"
    value = "true"
  }
}
