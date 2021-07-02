output "kubernetes_namespace" {
    value = kubernetes_namespace.this.metadata[0].name
}

# output "ingress_ip" {
#   value = "${kubernetes_ingress.example.load_balancer_ingress.0.ip}"
#   value = kubernetes_ingress.this
# }
