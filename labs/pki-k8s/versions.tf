terraform {
  required_version = ">= 0.14.0"
  required_providers {
    kubernetes-alpha = {
      source = "hashicorp/kubernetes-alpha"
      version = "0.2.1"
    }
  }
}
