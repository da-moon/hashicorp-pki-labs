
// resource "kubernetes_manifest" "test-configmap" {
//   provider = kubernetes-alpha
//   manifest = {
//     apiVersion = "v1"
//     kind = "ConfigMap"
//     metadata = {
//       "name" = "test-config"
//       "namespace" = "default"
//     }
//     data = {
//       "foo" = "bar"
//     }
//   }
// }
resource "kubernetes_manifest" "vault_issuer" {
  provider = kubernetes-alpha
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind = "Issuer"
    metadata = {
      "name" = "vault-issuer"
      #"namespace" = "web-server"
      "namespace" = var.kubernetes_namespace
    }
    spec = {
      vault = {
        auth = {
          kubernetes = {
            #mountPath = "/v1/test/auth/minikube"
            #role = "acme-dot-com"
            secretRef = {
              "key" = "token"
              "name" = var.secret_name
            }
            "role" = var.role_name
            "mountPath"   = "/v1/test/auth/${var.k8s_auth_mount}"
          }
        }
        namespace = "test"
        # path = "pki_int/sign/acme-dot-com"
        path = var.issuer_sign_path
        #server = "https://10.211.183.137:8200"
        server = var.vault_addr
      }
    }
  }
}
resource "kubernetes_manifest" "echo_server_certificate" {
  provider = kubernetes-alpha
  manifest = {
    apiVersion = "cert-manager.io/v1alpha3"
    kind = "Certificate"
    metadata = {
      "name" = var.application_k8s_ingress_secret_name
      "namespace" = var.kubernetes_namespace
    }
    spec = {
      commonName = var.root_domain
      dnsNames = [
        var.application_host,
      ]
      duration = "2h"
      issuerRef = {
        name = "vault-issuer"
      }
      renewBefore = "10m"
      secretName = var.application_k8s_ingress_secret_name
    }
  }
}
