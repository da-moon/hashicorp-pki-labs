

variable "kubernetes_namespace" {
  description = "Kuberentes namespace with this module's application"
  default     = "web-server"
  type        = string
}
variable "service_name" {
  description = "Application Service name"
  default     = "echo-server"
  type        = string
}
variable "service_port" {
  description = "Application Service Port"
  default     = "5678"
  type        = string
}
variable "host" {
  description = "Application Service host"
  default     = "us-west-1.acme.com"
  type        = string
}
variable "secret_name" {
  description = "Application Service Port"
  default     = "echo-server-certificate"
  type        = string
  sensitive   = true
}
