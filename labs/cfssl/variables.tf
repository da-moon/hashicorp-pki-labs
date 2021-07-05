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
variable "ca_common_name" {
  type        = string
  default     = "acme.com"
  description = "common name of root ca"
}
variable "ca_key_algorithm" {
  type        = string
  default     = "rsa"
  description = "root ca key algorithm"
}
variable "ca_key_size" {
  type        = number
  default     = 2048
  description = "root ca key size"
}
variable "ca_ttl" {
  description = "ttl and max ttl of root ca. Defaults to 10 years"
  default     = "315360000"
  type        = string
}
