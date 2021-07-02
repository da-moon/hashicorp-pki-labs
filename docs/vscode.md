# visual studio code

- [visual studio code](#visual-studio-code)
  - [overview](#overview)
  - [windows](#windows)
  - [debian](#debian)
  - [vscode setup](#vscode-setup)

## overview

VSCode (Visual Studio Code) is a free, extensible text-editor from
Microsoft in contrast with the famous `Visual Studio`, which is a
complete IDE.It's rich extension ecosystem makes VSCode a great tool
for programmers.

In this document, I will walk you through installing VSCode on windows or
a Debian Based Linux

## windows

If you have a package manager, such as [`scoop`](https://scoop.sh)
installed, you can simply install vscode by running the following
snippet in a powershell window.

```powershell
scoop install vscode
```

## debian

- [`vscode-installer`](../../scripts/installer/vscode) script can be
used to quickly install vscode on debian based machines

## vscode setup

confirm vscode is installed by running the following

```bash
code --version
```

if the previous command returned vscode version, your install was successful
and you can start installing vscode extensions. run the following snippet in
the shell you have already opened. this snippet installs remote development
extension pack and some extra useful extensions

```bash
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-ssh-edit
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
code --install-extension redhat.vscode-yaml
code --install-extension vscoss.vscode-ansible
code --install-extension wmaurer.change-case
code --install-extension bungcip.better-toml
code --install-extension aaron-bond.better-comments
code --install-extension wayou.vscode-todo-highlight
```
