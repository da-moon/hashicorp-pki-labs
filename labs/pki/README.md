# pki-lab

## overview

the purpose of this lab is to show how to enable pki secret engine and use it for generation of self signed certificates

## requirements

- running vault server
  - set `VAULT_ADDR` environment variable in your shell
  - set `VAULT_TOKEN` environment variable in your shell
- Terraform
- curl
- jq
- openssl

## usage

- initialize terrafrom modules

```bash
terraform init
```

- [OPTIONAL] for working with a clean slate,ensure any provisioned pki engine with this module is destroyed

```bash
terraform destroy -auto-approve
```

- apply the changes

```bash
terraform apply -auto-approve
```

- analyze a certificate with `openssl`

```bash
cat /path/to/cert | openssl x509 -text
```

### operations

| Description                                        	| Vault CLI Command                                                                 	| Curl Command                                                                                                                                               	|
|----------------------------------------------------	|-----------------------------------------------------------------------------------	|------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| generate a new self-signed certificate             	| `vault write <intermdiate-pki>/issue/<role> common_name=<common-name>`            	| `curl -fSsl -XPOST -H "X-Vault-Token: ${VAULT_TOKEN}"-d '{"common_name": "<common-name>"}' "${VAULT_ADDR}/v1/<intermediate--pki>/issue/<role-name>"`       	|
| list generated self-signed certificates            	| `vault list <intermdiate-pki>/certs`                                              	| `curl -fSsl -XLIST -H "X-Vault-Token: ${VAULT_TOKEN}" "${VAULT_ADDR}/v1/<intermdiate-pki>/certs"`                                                          	|
| revoke a certificate                               	| `vault write <intermdiate-pki>/revoke serial_number=<cert-serial-number>`         	| `curl -fSsl -XPOST -H "X-Vault-Token: ${VAULT_TOKEN}" -d '{"serial_number": "<cert-serial-number>"}' "${VAULT_ADDR}/v1/<intermdiate-pki>/revoke"`          	|
| cleanup pki engine and remove revoked certificates 	| `vault write <intermdiate-pki>/tidy tidy_cert_store=true tidy_revoked_certs=true` 	| `curl -fSsl -XPOST -H "X-Vault-Token: ${VAULT_TOKEN}" -d '{"tidy_cert_store": true,"tidy_revoked_certs":true }' "${VAULT_ADDR}/v1/<intermdiate-pki>/tidy"` 	|
