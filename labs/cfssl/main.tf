#-*-indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:


resource "docker_image" "this" {
  name = var.image_name
}
resource "docker_volume" "ca" {
  name = "${var.container_name}-ca"
}
data "template_file" "ca_csr" {
  template = file("${path.module}/templates/ca-csr.json.tpl")
  vars = {
    COMMON_NAME = var.ca_common_name
    KEY_ALGO    = var.ca_key_algorithm
    KEY_SIZE    = var.ca_key_size
    CA_TTL      = var.ca_ttl
  }
}
# initialize cfssl root ca
resource "docker_container" "ca_csr" {
  depends_on = [
    docker_image.cfssl,
    docker_volume.ca,
    data.template_file.ca_csr,,
  ]
  image = docker_image.cfssl.latest
  rm    = true
  volumes {
    container_path = "/var/cfssl"
    host_path = "${path.module}/ca"
    # volume_name    = docker_volume.ca.name
  }
  upload {
    file    = "/etc/cfssl/ca-csr.json"
    content = data.template_file.ca_config.rendered
  }
  command = [
  ]
}
# resource "docker_container" "cffsl_service" {
  # depends_on = [
    # docker_image.cfssl,
  # ]
  # image = docker_image.cfssl.latest
  # name  = var.container_name
  # rm    = true
  # ports {
    # internal = var.container_port
    # external = var.host_port
  # }
  # command = [
    # "serve",
    # "-address=0.0.0.0"
  # ]
# }
