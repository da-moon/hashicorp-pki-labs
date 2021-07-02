
# lxc

- [lxc](#lxc)
  - [overview](#overview)
  - [LXC ecosystem](#lxc-ecosystem)
  - [user setup](#user-setup)
  - [installation](#installation)
  - [initialization](#initialization)
  - [bare-bone container setup](#bare-bone-container-setup)
  - [common commands](#common-commands)
  - [references](#references)

## overview

[`LXC`](https://linuxcontainers.org) or `Linux Containers`, managed ,
developed and maintained by [`Canonical`](https://canonical.com) refers to a
suite of command line utilities focused on creating and orchestrating
`system containers` , whether they are running in standalone environment
or a cluster.

`system containers` or `OS containers` refer to containerization technologies
which offer an environment as close as possible as the one you'd get
from a `Virtual Machine`, such as `Libvirt`, `QEMU` or `Oracle Virtualbox`
but without the overhead that comes with running a resource hungry hypervisor
and a separate kernel which simulating all the hardware.

In practice, I find `system containers` to offer more freedom and
interactivity compared with `application containers` such as Docker.

The following is a non-exhaustive list of why I choose to use `LXC` to provide
and setup development environments for repositories:

- ease of use : Personally speaking, I find `LXC` to be much simpler to use
compared with Docker.
- interactivity : `LXC` offers a larger degree of freedom to install and
run software within it's containers since it was meant to be a replacement,
for most cases to virtual machines. It is quite easy to get a shell and
run commands the same way you would run them in your native OS shell.
- high-privilege : it is quite easy to setup `LXC` ro run application that
need higher privilege, such as access to certain Linux kernel API or CPU
execution ring 2/1 in `LXC`. You can also run nested containers within `LXC`,
for instance run a Docker container inside `LXC` container.
- architecture emulation : it is rather easy to emulate foreign CPU
architecture inside `LXC` containers. For instance, you host machine may
have `x86_64` architecture but you are developing for `AARCH64`.
You can have the container emulate `AARCH64` cpu architecture.
- simple clustering : I find setting up and managing a distributed
cluster with `LXC` to be extremely easy, compared with alternative.

To sum up, I believe `LXC` is a great tool for setting up development and
staging environment since it is much simpler to use and much less resource
hungry when compared with alternatives.

## LXC ecosystem

Primarily speaking, installing `LXC` add two main executables to your system :

- `lxd`: `lxd` is the 'brain' of the ecosystem. It is a `daemon`
that provides main containerization functionality, such as
container runtime and agent.
It exposes a API to control behavior and interact with it,
such as launching a new container.
- `lxc` : `lxc` is nothing but a 'client' to `lxd`. Essentially,
it provides an easy to use interface to send requests to `lxd` API and
interact with it.`lxc` is the software that end-users use most often.

the biggest issue with `LXC` is that `lxd` is only available on Linux
machines, since at it's core , `lxd` uses some linux libraries such as
`libvirt` and needs access to some features unique to Linux Kernel.

on the other hand, `lxc` is available on every platform so as long as
you have `lxd` running on some remote linux machine, you can use `lxc` to
interact with it and use it.

## user setup

this step is optional. If you haven't created a user on your debian machine
and only available user is `root`, which is the case for most debian buster
images, then you must install some base software and create a new user.

- install `sudo` and `apt-utils` packages

```bash
apt update && apt install -y sudo apt-utils
```

- we will create a default user . lets call it 'damoon' and set
it's password to damoon.

```bash
export username="damoon"; \
useradd \
  -l \
  -G sudo \
  -md "/home/${username}" \
  -s /bin/bash \
  -p password "${username}" && \
echo "${username}:${username}" | chpasswd && \
sed -i.bak \
-e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
/etc/sudoers && \
unset "${username}"
```

## installation

While it is most certainly possible to compile LXC from source, it can be
quite cumbersome. The official, most updated LXC release is available
only through [`Snap`](https://snapcraft.io/) package manager.
From my experience , `Debian` and `Ubuntu` derivative distros offer the
most frictionless experience with `Snap` package manager.

after installing snap, run the following in terminal to
install [`LXC`](https://snapcraft.io/lxd) :

```bash
sudo apt install -y snapd && \
sudo snap install core && \
sudo snap install lxd && \
sudo usermod -aG lxd "$USER" && \
newgrp lxd
```

## initialization

After installing, you must initilize `lxd`.

run the following in terminal and __accept defaults for all prompts__ :

```bash
sudo lxd init
```

## bare-bone container setup

I have prepared a instructions so that you can quickly launch a
new `Debian Buster` container, called `lex_dee` and install base
dependencies and configure the system.
These instructions were written with assumption that you are using a
Debian/Ubuntu derivative distro on your Host OS

- confirm install/confirm existence of dependencies on Host OS: open
terminal in your Host OS and run the following snippet
  - `jq` is used for creating and parsing json payload. we will use 'lxd'
  to get a reply from 'lxd' with all the containers and use 'jq' to parse
  the response and find out container's IP 'dynamically' so that we can ssh
  into it later on.
  - `sshpass` is used to ssh into the lxc container with password
  non-interactively, i.e no need to manually type password of
  the user we are ssh'ing into

```bash
sudo apt-get update &&
sudo apt-get install -yq \
                      jq \
                      sshpass
```

- I have prepared a small executable cli to take care of common
provisioning operation using cloud-init profiles and bash scripts
to help with starting containers.
the script is called [`lxd-debian`](https://github.com/da-moon/provisioner-scripts/blob/master/bash/util/lxd-debian). run `lxd-debian --help` to learn more.

## common commands

- create a new debian 10 machine called `lex_dee`

```bash
lxc launch images:debian/buster lex_dee
```

- get root shell into `lex_dee`

```bash
lxc exec lex_dee bash
```

- list all containers

```bash
lxc list
```

- Get `ssh` access to `lex_dee` container as `lex_dee` user

```bash
ssh "lex_dee@$(lxc list --format json \
| jq -r ".[] \
| select((.name==\"lex_dee\") and (.status==\"Running\"))" \
| jq -r '.state.network.eth0.addresses' \
| jq -r '.[] | select(.family=="inet").address')"
```

- take a file out of running `lex_dee` container with `scp`

```bash
scp "lex_dee@$(lxc list --format json \
| jq -r ".[] | select((.name==\"lex_dee\") and (.status==\"Running\"))" \
| jq -r '.state.network.eth0.addresses' \
| jq -r '.[] | select(.family=="inet").address')":/path/on/container \
/path/to/store/on/host
```

## references

- https://linuxcontainers.org/
