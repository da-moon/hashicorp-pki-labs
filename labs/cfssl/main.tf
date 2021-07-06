#-*-indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:
resource "docker_image" "this" {
  name = var.image_name
}
resource "docker_volume" "this" {
  name = var.container_name
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
data "template_file" "cfssl_config" {
  template = file("${path.module}/templates/cfssl.json.tpl")
  vars = {
    DEFAULT_TTL = var.ca_ttl
    CERT_TTL    = var.cert_ttl
  }
}
# initialize cfssl root ca
resource "docker_container" "ca_csr" {
  depends_on = [
    docker_image.this,
    docker_volume.this,
    data.template_file.ca_csr,
  ]
  name           = "${var.container_name}_ca_csr"
  image          = docker_image.this.latest
  rm             = true
  remove_volumes = false
  must_run       = false
  volumes {
    container_path = "${var.cfssl_data_dir}/ca"
    host_path      = abspath("${path.module}/certificates/ca")
  }
  upload {
    file    = "${var.cfssl_config_dir}/ca-csr.json"
    content = data.template_file.ca_csr.rendered
  }
  working_dir = "${var.cfssl_data_dir}/ca"
  entrypoint  = [""]
  command = [
    "/bin/bash",
    "-c",
    "rm -f * && cfssl gencert -initca ${var.cfssl_config_dir}/ca-csr.json | cfssljson -bare ca"
  ]
}
# eq
# docker run -v "cfssl:/var/cfssl" -v "$PWD/certificates/server:/var/cfssl/server"  --workdir "/var/cfssl/server" --entrypoint "" --rm -it cfssl/cfssl /bin/bash
resource "docker_container" "server_cert" {
  depends_on = [
    docker_image.this,
    docker_volume.this,
    docker_container.ca_csr,
    data.template_file.cfssl_config,
  ]
  name           = "${var.container_name}_server"
  image          = docker_image.this.latest
  rm             = true
  remove_volumes = false
  must_run       = false
  upload {
    file    = "${var.cfssl_config_dir}/cfssl.json"
    content = data.template_file.cfssl_config.rendered
  }
  volumes {
    container_path = "${var.cfssl_data_dir}/ca"
    host_path      = abspath("${path.module}/certificates/ca")
  }
  volumes {
    container_path = "${var.cfssl_data_dir}/server"
    host_path      = abspath("${path.module}/certificates/server")
  }
  working_dir = "${var.cfssl_data_dir}/server"
  entrypoint  = [""]
  command = [
    "/bin/bash",
    "-c",
    "rm -f * && echo '{}' | cfssl gencert -ca=${var.cfssl_data_dir}/ca/ca.pem -ca-key=${var.cfssl_data_dir}/ca/ca-key.pem -config=${var.cfssl_config_dir}/cfssl.json -hostname='localhost,127.0.0.1,vault-1,vault-1.local,vault-2,vault-2.local,vault-3,vault-3.local,consul-server-1,consul-server-1.local,consul-server-2,consul-server-2.local,consul-server-3,consul-server-3.local' - | cfssljson -bare"
  ]
}
resource "docker_container" "client_cert" {
  depends_on = [
    docker_image.this,
    docker_volume.this,
    docker_container.ca_csr,
    data.template_file.cfssl_config,
  ]
  name           = "${var.container_name}_client"
  image          = docker_image.this.latest
  rm             = true
  remove_volumes = false
  must_run       = false
  upload {
    file    = "${var.cfssl_config_dir}/cfssl.json"
    content = data.template_file.cfssl_config.rendered
  }
  volumes {
    container_path = "${var.cfssl_data_dir}/ca"
    host_path      = abspath("${path.module}/certificates/ca")
  }
  volumes {
    container_path = "${var.cfssl_data_dir}/client"
    host_path      = abspath("${path.module}/certificates/client")
  }
  working_dir = "${var.cfssl_data_dir}/client"
  entrypoint  = [""]
  command = [
    "/bin/bash",
    "-c",
    "rm -f * && echo '{}' | cfssl gencert -ca=${var.cfssl_data_dir}/ca/ca.pem -ca-key=${var.cfssl_data_dir}/ca/ca-key.pem -config=${var.cfssl_config_dir}/cfssl.json -hostname='localhost,127.0.0.1,vault-1,vault-1.local,vault-2,vault-2.local,vault-3,vault-3.local,consul-client-1,consul-client-1.local,consul-client-2,consul-client-2.local,consul-client-3,consul-client-3.local' - | cfssljson -bare client"
  ]
}
resource "docker_container" "cli_cert" {
  depends_on = [
    docker_image.this,
    docker_volume.this,
    docker_container.ca_csr,
    data.template_file.cfssl_config,
  ]
  name           = "${var.container_name}_cli"
  image          = docker_image.this.latest
  rm             = true
  remove_volumes = false
  must_run       = false
  upload {
    file    = "${var.cfssl_config_dir}/cfssl.json"
    content = data.template_file.cfssl_config.rendered
  }
  volumes {
    container_path = "${var.cfssl_data_dir}/ca"
    host_path      = abspath("${path.module}/certificates/ca")
  }
  volumes {
    container_path = "${var.cfssl_data_dir}/cli"
    host_path      = abspath("${path.module}/certificates/cli")
  }
  working_dir = "${var.cfssl_data_dir}/cli"
  entrypoint  = [""]
  command = [
    "/bin/bash",
    "-c",
    "rm -f * && echo '{}' | cfssl gencert -ca=${var.cfssl_data_dir}/ca/ca.pem -ca-key=${var.cfssl_data_dir}/ca/ca-key.pem -config=${var.cfssl_config_dir}/cfssl.json -hostname='localhost,127.0.0.1,vault-1,vault-1.local,vault-2,vault-2.local,vault-3,vault-3.local,consul-cli-1,consul-cli-1.local,consul-cli-2,consul-cli-2.local,consul-cli-3,consul-cli-3.local' - | cfssljson -bare cli"
  ]
}
resource "docker_container" "cffsl_api" {
  depends_on = [
    docker_image.this,
    docker_volume.this,
    docker_container.ca_csr,
    data.template_file.cfssl_config,
  ]
  image = docker_image.this.latest
  name  = var.container_name
  rm    = true
  upload {
    file    = "${var.cfssl_config_dir}/cfssl.json"
    content = data.template_file.cfssl_config.rendered
  }
  volumes {
    container_path = "${var.cfssl_data_dir}/ca"
    host_path      = abspath("${path.module}/certificates/ca")
  }
  ports {
    internal = var.container_port
    external = var.host_port
  }
  healthcheck {
    interval = "30s"
    timeout  = "3s"
    retries  = 5
    test = [
      "CMD",
      "curl",
      "-f",
      "http://localhost:${var.container_port}/api/v1/cfssl/health"
    ]
  }
  command = [
    "serve",
    "-ca-key=${var.cfssl_data_dir}/ca/ca-key.pem",
    "-ca=${var.cfssl_data_dir}/ca/ca.pem",
    "-config=${var.cfssl_config_dir}/cfssl.json",
    "-address=0.0.0.0"
  ]
}
