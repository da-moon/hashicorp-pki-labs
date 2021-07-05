#!/usr/bin/env bash
# -*- mode: sh -*-
# vi: set ft=sh:tabstop=2:softtabstop=2:shiftwidth=2:expandtab
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export SLEEP_DURATION=5
COLUMNS=100
stty columns ${COLUMNS}


#
# ─── FUNCTION SECTION ───────────────────────────────────────────────────────────
#
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
if [ -n "$(command -v apt-get)" ]; then
  export DEBIAN_FRONTEND=noninteractive
  echo >&2 "*** Detected Debian based Linux"
fi
if ! command -v "tput" >/dev/null ; then
  echo >&2  "*** 'tput' was not found in PATH"
  exit 1
fi
# [ NOTE ] => Bold
bold=$(tput bold)
# [ NOTE ] => Red Color
# red
red=$(tput setaf 1)
# [ NOTE ] => Green Color
green=$(tput setaf 2)
# [ NOTE ] => Yellow Color
yellow=$(tput setaf 3)
# [ NOTE ] => dark blue Color
dblue=$(tput setaf 4)
# [ NOTE ] => Reset color
reset=$(tput sgr0)
# printf-wrap
# Description:  Printf with smart word wrapping for every columns.
# Usage:        print-wrap "<text>" "<text>" ...
function printf-wrap () {
  local -r collen=$(($(tput cols)));
  local keyname="$1";
  local value=$2;
  while [ -n "$value" ] ; do
    printf >&2 "%-10s %-0s\n" "${keyname}" "${value:0:$collen}";
    keyname="";
    value=${value:$collen};
  done
}

function err() {
    local -r value=$1;
    local -r keyname="${bold}[   ${red}ERROR${reset}${bold}  ]${reset}"
    printf-wrap "${keyname}" "${value}"
}
function info() {
    local -r value=$1;
    local -r keyname="${bold}[   ${green}INFO${reset}${bold}   ]${reset}"
    printf-wrap "${keyname}" "${value}"
}

function warn() {
    local -r value=$1;
    local -r keyname="${bold}[  ${yellow}WARNING${reset}${bold} ]${reset}"
    printf-wrap "${keyname}" "${value}"
}

function section(){
  if [[ $# == 0 ]]; then
    err "this function needs arguments"
    exit 1
  fi
  local -r terminal_cols="$(tput cols)"
  while [[ $# -gt 0 ]]; do
    local key="$1"
    case "$key" in
      --message)
        local -r message="$2"
        echo >&2 ""
        info "${message}"
        echo >&2 ""
        shift
      ;;
      --params)
        local key="$2"
        shift
        local value="$2"
        shift
        key="[   ${bold}${key}${reset}   ] =>"
        value="${dblue}${value}${reset}"
        printf-wrap "${key}" "${value}"
      ;;
      --command)
        local command="$2"
        echo >&2 "${yellow}"
        printf "\n%${terminal_cols}s\n" | tr ' ' '-' >&2
        echo >&2 ""
        echo >&2 "  ${command}"
        echo >&2 ""
        printf "%${terminal_cols}s\n" | tr ' ' '-' >&2
        echo >&2 "${reset}"
        sleep "${SLEEP_DURATION}"
        bash -c "${command}"
        shift
      ;;
      *)
        err "unacceptable arg ${red}${key}${reset}"
        exit 1
      ;;
    esac
    shift
  done
  printf "\n%${terminal_cols}s\n" | tr ' ' '#' >&2
  sleep "${SLEEP_DURATION}"
  echo >&2 ""
}
echo >&2 ""
message="making sure all terraform modules are initialized"
command="terraform init"
section --message "$message" --command "$command"

message="using terraform to ${green}create${reset} ${bold}pki secret engine${reset}"
command="terraform apply -auto-approve"
section --message "$message" --command "$command"
