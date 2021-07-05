#-*-indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:


resource "docker_image" "cfssl" {
  name          = var.image_name
}
resource "docker_container" "cffsl_service" {
  depends_on=[
    docker_image.cfssl,
  ]
  image = docker_image.cfssl.latest
  name  = var.container_name
  rm    = true
  ports {
    internal = var.container_port
    external = var.host_port
  }
}