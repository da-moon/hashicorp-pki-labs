resource "vault_auth_backend" "this" {
  type       = "kubernetes"
  path       = var.auth_mount_path
}

#
# ────────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: V A U L T   S E R V I C E   A C C O U N T   S E T U P : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────────
#
resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.service_account_name
    namespace = var.service_account_namespace
  }
  automount_service_account_token = true
}
resource "kubernetes_cluster_role_binding" "this" {
  depends_on = [kubernetes_service_account.this]

  metadata {
    name = var.cluster_role_binding_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata[0].name
    namespace = var.service_account_namespace
  }
}
data "kubernetes_service_account" "this" {
  depends_on = [kubernetes_service_account.this]
  metadata {
    name = var.service_account_name
  }
}
data "kubernetes_secret" "this" {
  depends_on = [kubernetes_service_account.this]
  metadata {
    name = kubernetes_service_account.this.default_secret_name
  }
}
#
# ────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C O N F I G U R E   K 8 S   A U T H   M E T H O D : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────
#
# ────────────────────────────────────────────────────────────────────────────────
#
# ─── BASH EQUIVALANT COMMAND ────────────────────────────────────────────────────
#
# ────────────────────────────────────────────────────────────────────────────────
# export TF_VAR_kubernetes_host="https://$(minikube ip):8443"
# export TF_VAR_vault_sa_name="$(kubectl get sa vault-service-account -n default -o jsonpath="{.secrets[*]['name']}")"
# export TF_VAR_token_reviewer_jwt="$(kubectl get secret ${TF_VAR_vault_sa_name} -n default -o jsonpath="{.data.token}" | base64 --decode; echo)"
# export TF_VAR_kubernetes_ca_cert=$(kubectl get secret $VAULT_SA_NAME -n default -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
# vault write auth/minikube/config \
#   kubernetes_host="${TF_VAR_kubernetes_host}" \
#   token_reviewer_jwt="${TF_VAR_token_reviewer_jwt}" \
#   kubernetes_ca_cert="${TF_VAR_kubernetes_ca_cert}"
# ────────────────────────────────────────────────────────────────────────────────

resource "vault_kubernetes_auth_backend_config" "example" {
  depends_on = [
    data.kubernetes_service_account.this,
    data.kubernetes_secret.this,
  ]
  kubernetes_host        = var.kubernetes_host
  backend                = vault_auth_backend.this.path
  kubernetes_ca_cert     = lookup(data.kubernetes_secret.this.data, "ca.crt")
  token_reviewer_jwt     = lookup(data.kubernetes_secret.this.data, "token")
  issuer                 = "api"
  disable_iss_validation = "true"
}
