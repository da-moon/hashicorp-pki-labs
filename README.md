# hashicorp-pki-labs

- [hashicorp-pki-labs](#hashicorp-pki-labs)
  - [overview](#overview)
  - [VM Backed Labs](#vm-backed-labs)
    - [overview](#overview-1)
    - [requirements](#requirements)
    - [usage](#usage)
  - [docker-compose lab](#docker-compose-lab)
    - [overview](#overview-2)
    - [requirements](#requirements-1)
    - [usage](#usage-1)

## overview

the purpose of this repo is to act as a pre-provisioned lab environment for experimentation with
certificates and PKI infrastructure with Vault and Consul.

this document guides you through setting up your own local Vault cluster to use as lab environment. We have prepared two versions for you :

- VM backed lab environment : this environment brings up a production grade 3 node Vault cluster with HA Raft storage backed.

- docker-compose environment : docker-compose environment brings up 3 containers: one Consul node in Dev mode, One Vault Node in Dev mode and an alpine container, provisioned with the needed tools.

Refer to the following supplementary documentation to learn more about the technologies used in this repo.

- [lxd](docs/lxd.md) : notes on LXD and a bunch of common commands to make working with LXD easier
- [vscode](docs/vscode.md) : notes on Visual Studio Code setup

## VM Backed Labs

- [pki engine](labs/pki) lab : This lab shows how to enable pki secret engine and use it for generation and delivery of short-lived self signed certificates.
- [pki-k8s](labs/pki-k8s) lab : the purpose of this lab is to build a workflow that allows creation and lifecycle management of TLS Certificates in a kubernetes environement for all Applications that are exposed to the outside world.

### overview

[`vagrant`](https://vagrantup.com) is used to provision the VM. Current Vagrantfile supports Virtualbox, HyperV and Libvirt providers which means anyone, running on any OS can bring up this environment.

### requirements

- 4 GB free ram on their machine to dedicate to the . They can use 2 GB but that may cause the Lab cluster to be unstable.
- install Vagrant from official [site](https://www.vagrantup.com/downloads) ( not through any package managers )
- Have vt-x and nested virtualization enabled in their bios.
- Windows Users :
  - Most common backend is microsoft Hyper-V
  - They must have Windows 10 Pro/ Enterprise to Enable HyperV. Windows 10 Home does not support Hyper-V
  - the following snippet can be used to enable HyperV

```powershell
# Open Powershell As Administrator
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
# Restart after completion
```

  - Windows users can also use VirtualBox, only if they have not enabled HyperV on their system. HyperV is a [type 1 hypervisor](https://medium.com/teamresellerclub/type-1-and-type-2-hypervisors-what-makes-them-different-6a1755d6ae2c) and doesn't play nice with other hypervisors, meaning if you enable hyper-v, no other hypervisor can run on windows.

- Mac/Linux Users : install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  - Users on Debian based distros can use this script `contrib/scripts/installer/virtualbox` , i.e

```bash
bash contrib/scripts/installer/virtualbox
```

### usage


- Bring up the VM with desired Hypervisor ( e.g `virtualbox`)

```bash
vagrant up --provider=virtualbox
```

- Get inside the VM

```bash
vagrant ssh
```

- go to lab repository root

```bash
cd ~/vault-training
```

- Bring Up LXD containers that host Vault nodes

```bash
make -j$(nproc) vault-containers
```

- provision containers and install and setup vault

```bash
make vault
```

At this point, you have a complete lab environment. You can checkout cluster IP addresses by running `lxc ls` or you can access a node in the cluster , lets say `vault-1` with ssh : `ssh vault-1`

## docker-compose lab

### overview

This is more of a light-weight lab, used for showcasing Vault features in Dev mode.

### requirements

- docker engine and docker compose must be installed on your machine

### usage

- bring up the containers

```bash
docker-compose -f .devcontainer/docker-compose.devcontainer.yml up -d
```

- get a shell into the lab container

```bash
docker-compose -f .devcontainer/docker-compose.devcontainer.yml exec vault-training bash
```

- The docker-compose environment works with Visual Studio Code Remote developer Extension Pack for a seem-less experience
  - Install [`Microsoft Visual Studio Code`](https://code.visualstudio.com)
  - Install [`Remote Development Extension Pack`](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) on VSCode
  - Open the repository root in Visual studio code. you will see the following prompt in bottom right half of the screen. accept it and wait for the build/dev environment setup.
> Folder contains a Dev Container configuration file. Reopen folder to develop in a container ([learn more](https://aka.ms/vscode-remote/docker)).
  - in case you didn't see the prompt, press `ctrl+shift+p` and search for and run `remote-containers: rebuild and reopen in container`.
