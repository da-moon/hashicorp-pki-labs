# vault-lab

## Overview

Cloud agnostic Ansible playbooks used to deploy vault cluster backed by raft
storage engine in HA mode.

## Features

- Generate certificates with `cfssl` per remote server and encrypt them with
`ansible-vault`
- Generate and encrypt and store gossip encryption key for vault cluster
- Bootstrap and unseal the cluster using Shamir secret sharing without relying
on any cloud specific KMS provider or transit secrets engine.
- No need for a Consul cluster. The configuration uses Vault's new raft
storage engine, so the cluster is not dependant on any other service.

## Snippets

- check connectivity

```bash
ansible -i staging -m ping all -vvv
```

- Generate a random password to encrypt data with `ansible-vault` and store it
in `~/.vault_pass.txt`.This file already exists in the Vagrant box so there
is no need to run it if your Ansible controller is the Vagrant box.

```bash
echo \
  -n "$(dd if=/dev/urandom bs=64 count=1 status=none | base64)" \
| tee ~/.vault_pass.txt
```

- in case your host machine is a remote server (lxd is running on remote),
you might want to access vault api at `https://localhost:8200`.
use the following snippet on host to redirect all connections to
port `8200` to a single Vault agent's container

```bash
lxc config device \
  add "vault-1" "proxy-vault-1" \
  proxy listen=tcp:0.0.0.0:8200 connect=tcp:127.0.0.1:8200
```

remove the proxy with the following snippet :

```bash
lxc config device remove "vault-1" "proxy-vault-1"
```

- set host environment variables by adding them to bashrc ~/.bashrc

```bash
sed -i '/VAULT/d' ~/.bashrc && \
cat << EOF | tee -a ~/.bashrc
export VAULT_ADDR="https://$(lxc list --format json \
| jq -r ".[] \
| select((.name | contains(\"vault\")) and (.status==\"Running\"))" \
| jq -r '.state.network.eth0.addresses' \
| jq -r '.[] \
| select(.family=="inet").address' \
| head -n 1):8200"
export VAULT_SKIP_VERIFY=true
export VAULT_TOKEN="$(find -name vault_root_token.yml \
| xargs -I {} cat {} \
| yq -r .vault_root_token \
| ansible-vault view --vault-password-file ~/.vault_pass.txt -)"
EOF
```

- decrypt  `vault_root_token`

```bash
find -name vault_root_token.yml | xargs -I {} ansible localhost \
  -m debug \
  -a var="vault_root_token" \
  -e "@{}" \
  --vault-password-file ~/.vault_pass.txt
```

- decrypt  `vault_unseal_keys_b64`

```bash
find -name vault_unseal_keys_b64.yml | xargs -I {} ansible localhost \
  -m debug \
  -a var="vault_unseal_keys_b64" \
  -e "@{}" \
  --vault-password-file ~/.vault_pass.txt
```

- Setup Ansible Controller Software

```bash
ansible-playbook \
  -i staging \
  --tags 01-ansible-controller \
  site.yml
```

- Setup base dependencies for all inventory hosts

```bash
ansible-playbook \
  -i staging \
  --tags 02-install-prerequisites \
  site.yml
```

- install Vault

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging \
  --tags 03-install-vault \
  site.yml
```

- generate certificates for Vault

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging \
  --tags 04-vault-certificates \
  site.yml
```

- configure Vault

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging \
  --tags 05-configure-vault \
  site.yml
```

- unseal Vault

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging \
  --tags 06-unseal-vault \
  site.yml
```

## references

- <https://learn.hashicorp.com/tutorials/vault/reference-architecture>
