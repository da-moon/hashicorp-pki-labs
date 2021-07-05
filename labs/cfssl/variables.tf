#-*-indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
variable "image_name" {
  type    = string
  default = "cfssl/cfssl"
}
variable "docker_host" {
  type    = string
  default = "unix:///var/run/docker.sock"
}
variable "container_name" {
  type    = string
  default = "cfssl"
}
variable "container_port" {
  type    = number
  default = 8888
}
variable "host_port" {
  type    = number
  default = 8888
}