## overview

the purpose of this lab is to build a
workflow that allows creation and lifecycle management of TLS Certificates in a
Kubernetes environnement for all Applications that are exposed to the outside
world.

To do so, :
-  PKI secret engine : we will deploy a Vault Server which will act as Root
PKI and Intermediate PKI and will provide API endpoint for issuing Certificates
-  D and configure JetStack `cert-manager`
-  integrate Certificate Controller Manager with Vault.

In terms of workflow, it can be describe as follow:

- `cert-manager` checks if a change occurs at the certificate object level
and will use the information provided and sends a request through the issuer
to Vault, since
Vault is supporting our Root and Intermediate PKI.
-   Vault will validate the identity and permissions of `cert-manager` issuer
through Kubernetes authentication method Before giving back a signed certificate.
- As soon as identity is validated, Vault will create and deliver a specific certificate, valid for 10 minutes which is signed by the intermediate CA.
-  `cert-manager` will store the certificate as a Kubernetes secrets in ETCD and will renew as needed in regards of the lifetime of the certificate.

## requirements

- running vault server
  - set `VAULT_ADDR` environment variable in your shell
  - set `VAULT_TOKEN` environment variable in your shell
- Terraform
- curl
- jq
- `helm` and `minikube`
- openssl

## internals

### Kubernetes

- Create a namespace for `cert-manager` + Application namespace
- Create `Vault Service Account` and the `clusterRoleBinding` so that vault can validate the identity of the Pod through k8s API
- Deploy and configure `cert-manager` using `helm`
- Create a `cert-manager` service account in the application namespace allowing the certificate issuer to authenticate through Vault
- Configure ingress route for our App
- Create the Certificate object related to the application inside the Application namespace

### Vault

- Configure Kubernetes Authentication Method to allow `cert-manager` to authenticate using a service account
- Configure Vault PKI Secret Engine with a role to be able to issue certificates on demand
- Configure a policy called that allow access to PKI to be able sign request and issue certificate

## usage

- you must run these commands inside the Lab VM.
- ensure vault cluster is up and running

```bash
make -j`nproc` vault-containers && make vault
```
- initialize minikube

```bash
minikube start
```

- add nginx ingress

```bash
minikube addons enable ingress
```

- set `kubernetes_host` terraform variable through shell Env vars

```bash
export TF_VAR_kubernetes_host="https://$(minikube ip):8443"
```

- initialize terrafrom modules

```bash
terraform init
```

- [OPTIONAL] for working with a clean slate,ensure any provisioned pki engine with this module is destroyed

```bash
terraform destroy -auto-approve
```

- apply `pki` module : sets up PKI engine

```bash
terraform apply -target=module.pki -auto-approve
```

- apply `k8s` module : sets up k8s auth

```bash
terraform apply -target=module.k8s -auto-approve
```

- apply `application` module : deploys a sample echo webserver

```bash
terraform apply -target=module.application -auto-approve
```

- apply `cert_manager` module : deploys and configures `cert-manager`

```bash
terraform apply -target=module.cert_manager -auto-approve
```

- apply `manifests` module : applies certmanger related `Issuer` and `Certificate` manifests

```bash
terraform apply -target=module.manifests -auto-approve
```

- get all service accounts in `default` namespace

```bash
kubectl get sa -n default
```

- get all pods in `cert-manager` namespace

```bash
kubectl get pods -n cert-manager
```

- get all service accounts in `web-server` namespace

```bash
kubectl get sa -n web-server
```

- get all issuers in `web-server` namespace

```bash
kubectl get issuer -n web-server
```

- get all certificates in `web-server` namespace

```bash
kubectl get certificate -n web-server
```

- get all ingress in `webserver` namespace

```bash
kubectl get ingress -n web-server
```

- update `/etc/hosts` to ensure deployed webserver hostname is accessible

```bash
sudo sed -i "/$(kubectl get ingress  -n web-server  -o jsonpath="{.items[*].spec.rules[*].host}")/d" /etc/hosts
```

- confirm ingress is working and directing traffic

```bash
curl "$(kubectl get ingress -n web-server  -o jsonpath="{.items[*].spec.rules[*].host}")"
```

- confirm `certmanager` has delivered a certificate by checking server certificate's fingerprint

```bash
echo | openssl s_client -servername local -connect "$(kubectl get ingress -n web-server  -o jsonpath="{.items[*].spec.rules[*].host}"):443" 2>/dev/null | openssl x509 -noout -fingerprint
```
