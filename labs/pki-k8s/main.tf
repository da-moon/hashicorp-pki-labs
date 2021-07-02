
module "pki" {
  source                              = "./modules/pki"
  root_ttl                            = var.root_ttl
  int_ttl                             = var.int_ttl
  cert_ttl                            = var.cert_ttl
  organization                        = var.organization
  vault_domain_address                = var.vault_domain_address
  root_pki_path                       = var.root_pki_path
  int_pki_path                        = var.int_pki_path
  root_domain                         = var.root_domain
  subdomains                          = var.subdomains
}
module "k8s" {
  depends_on                          = [module.pki]
  source                              = "./modules/k8s"
  auth_mount_path                     = var.k8s_auth_path
  service_account_namespace           = var.vault_k8s_sa_namespace
  service_account_name                = var.vault_k8s_sa_name
  cluster_role_binding_name           = var.vault_k8s_rb_name
  kubernetes_host                     = var.kubernetes_host
}
module "application" {
  depends_on                          = [module.k8s]
  source                              = "./modules/application"
  kubernetes_namespace                = var.application_k8s_namespace
  service_name                        = var.application_k8s_service_name
  service_port                        = var.application_k8s_ingress_service_port
  host                                = local.applciation_host
  secret_name                         = var.application_k8s_ingress_secret_name
}

module "cert_manager" {
  depends_on                          = [module.application]
  source                              = "./modules/cert-manager"
  service_account_namespace           = var.cert_manager_k8s_namespace
  service_account_name                = var.cert_manager_k8s_sa_name
  cert_manager_version                = var.cert_manager_version
  application_namespace               = module.application.kubernetes_namespace
  k8s_auth_mount                      = module.k8s.auth_mount_path
  pki_policy_name                     = module.pki.policy_name
}
module "manifests" {
  depends_on                          = [module.cert_manager]
  source                              = "./modules/manifests"
  secret_name                         = module.cert_manager.secret_name
  role_name                           = module.cert_manager.role_name
  kubernetes_namespace                = module.application.kubernetes_namespace
  issuer_sign_path                    = module.pki.int_pki_sign_path
  vault_addr                          = var.vault_addr
  root_domain                         = var.root_domain
  application_k8s_ingress_secret_name = var.application_k8s_ingress_secret_name
  application_host                    = local.applciation_host
  k8s_auth_mount                      = module.k8s.auth_mount_path
}
