resource "kubernetes_namespace" "this" {
  metadata {
    name = var.kubernetes_namespace
  }
}
resource "kubernetes_deployment" "this" {
  depends_on  = [
    kubernetes_namespace.this,
  ]
  metadata {
    name = var.service_name
    namespace = kubernetes_namespace.this.metadata[0].name
    labels = {
      app =  var.service_name
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.service_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.service_name
        }
      }

      spec {
        container {
          name  = var.service_name
          image = "fjolsvin/http-echo-rs:latest"
          args  = [
            "--listen",":${var.service_port}",
            "--text","hello rust from k8s!"
          ]
          port {
            container_port = var.service_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  depends_on  = [
    kubernetes_deployment.this,
  ]
  metadata {
    name = kubernetes_deployment.this.metadata[0].name
    labels = {
      app = var.service_name
    }
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    type = "NodePort"
    selector = {
      app = kubernetes_deployment.this.metadata[0].name
    }
    port {
      name        = var.service_name
      port        = var.service_port
      target_port = var.service_port
    }
  }
}

resource "kubernetes_ingress" "this" {
  depends_on  = [
    kubernetes_service.this,
  ]
  metadata {
    name      = var.service_name
    namespace = kubernetes_namespace.this.metadata[0].name
    // labels = {
    //   app =  "nginx-http-server-ingress"
    // }
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
    }

  }
  spec {
    tls {
      hosts = [
        var.host
      ]
      secret_name = var.secret_name
    }
    rule {
      host = var.host
      http {
        path {
          backend {
            service_name = var.service_name
            service_port = var.service_port
          }
          path = "/"
        }
      }
    }
  }
}
