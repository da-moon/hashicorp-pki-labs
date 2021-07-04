#!/usr/bin/env bash
# -*- mode: sh -*-
# vi: set ft=sh:tabstop=2:softtabstop=2:shiftwidth=2:expandtab
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export SLEEP_DURATION=0
COLUMNS=100
stty columns ${COLUMNS}
#
# ─── PASSING OR FAILING TEST CASES ──────────────────────────────────────────────
#
passing_common_names=(
  "localhost"
  "us-west-1.acme.com"
  "us-east-1.acme.com"
  "apac-southeast-1.acme.com"
  "eu-central.acme.com"
)
failing_common_names=(
"www.acme.com"
"acme.com"
"*.acme.com"
"test.acme.ncomet"
)
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
#
# ──────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: S C R I P T   E X E C U T I O N   S T A R T : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────────
#


#
# ─── PREPARING INFRA WITH TERRAFORM ─────────────────────────────────────────────
#

message="making sure all terraform modules are initialized"
command="terraform init"
section --message "$message" --command "$command"

message="using terraform to ${green}create${reset} ${bold}pki secret engine${reset}"
command="terraform apply -auto-approve"
section --message "$message" --command "$command"

rand_common_name="$[$RANDOM % ${#passing_common_names[@]}]"
acceptable_common_name="${passing_common_names[$rand_common_name]}"
rand_common_name="$[$RANDOM % ${#passing_common_names[@]}]"
acceptable_alt_name="${passing_common_names[$rand_common_name]}"

#
# ─── SHOWCASING CERTIFICATE GENERATION ──────────────────────────────────────────
#

#
# ──────────────────────────────────────────────────────────────────── I ──────────
#   :::::: W I T H   V A U L T   C L I : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────
#
message="using  ${yellow}vault write${reset} command with the following parameters to generate a certificate"
command="vault write pki_int/issue/acme-dot-net common_name=$acceptable_common_name alt_names=${acceptable_alt_name}"
section --message "${message}" --params "common_name" "${acceptable_common_name}" --params "alt_name" "${acceptable_alt_name}" --command "${command}"

#
# ────────────────────────────────────────────────────────── I ──────────
#   :::::: W I T H   C U R L : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────
#
tmpcert=$(mktemp)
command=$(cat <<EOF
jq -n \
--arg common_name "${acceptable_common_name}" \
--arg alt_names "${acceptable_alt_name}" \
'{"common_name": \$common_name,"alt_names": \$alt_names}' | \
curl -fSsl \
--header "X-Vault-Token: ${VAULT_TOKEN}" \
--request POST \
--data @- \
"${VAULT_ADDR}/v1/pki_int/issue/acme-dot-net" | jq -r '.' > ${tmpcert}
EOF
)

message="using ${yellow}curl${reset} command and storing certificate in ${bold}${tmpcert}${reset} for further analysis"
section --message "$message" --command "$command"

#
# ─── LISTING GENERATED CERTIFICATE ──────────────────────────────────────────────
#

#
# ──────────────────────────────────────────────────────────────────── I ──────────
#   :::::: W I T H   V A U L T   C L I : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────
#
message="using ${yellow}vault list${reset} to list generated certificate"
command="vault list pki_int/certs"
section --message "$message" --command "$command"

#
# ────────────────────────────────────────────────────────── I ──────────
#   :::::: W I T H   C U R L : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────
#
command=$(cat <<EOF
curl \
--header "X-Vault-Token: ${VAULT_TOKEN}" \
--request LIST \
${VAULT_ADDR}/v1/pki_int/certs
EOF
)
message="using ${yellow}curl${reset} to list generated certificate"
section --message "$message" --command "$command"
#
# ─── SHOWCASING CERTIFICATE ANALYSIS WITH OPENSSL ───────────────────────────────
#
command="cat ${tmpcert} | jq -r '.data.certificate' | openssl x509 -text"
message="using ${yellow}openssl${reset} to analyse the certificate stored at ${bold}${tmpcert}${reset}"
section --message "$message" --command "$command"

#
# ─── REVOKING GENERATED CERTIFICATE ─────────────────────────────────────────────
#

#
# ──────────────────────────────────────────────────────────────────── I ──────────
#   :::::: W I T H   V A U L T   C L I : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────
#
command="cat ${tmpcert} | jq -r '.data.serial_number' | xargs -I {} vault write pki_int/revoke serial_number={}"
message="using ${yellow}vault write${reset} to revoke certificate stored at ${bold}${tmpcert}${reset} which has serial number ${bold}$(cat ${tmpcert} | jq -r '.data.serial_number')${reset}"
section --message "$message" --command "$command"
#
# ────────────────────────────────────────────────────────── I ──────────
#   :::::: W I T H   C U R L : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────
#
command=$(cat <<EOF
curl -fSsl \
--header "X-Vault-Token: ${VAULT_TOKEN}" \
--request LIST ${VAULT_ADDR}/v1/pki_int/certs | \
jq -r '.data.keys[2]' | \
xargs -I {} jq -n \
--arg serial_number "{}" \
'{"serial_number": \$serial_number}' | \
curl -fSsl \
--header "X-Vault-Token: ${VAULT_TOKEN}" \
--request POST \
--data @- \
"${VAULT_ADDR}/v1/pki_int/revoke"
EOF
)
message="using ${yellow}curl${reset} to revoke certificate stored with has serial number ${bold}$(curl --header "X-Vault-Token: ${VAULT_TOKEN}" --request LIST ${VAULT_ADDR}/v1/pki_int/certs | jq -r '.data.keys[1]')${reset}"
section --message "$message" --command "$command"

#
# ─── TIDYING UP REVOKED CERTS ───────────────────────────────────────────────────
#
#
# ──────────────────────────────────────────────────────────────────── I ──────────
#   :::::: W I T H   V A U L T   C L I : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────
#
command="vault write pki_int/tidy tidy_cert_store=true tidy_revoked_certs=true"
message="using ${yellow}vault write${reset} to ${bold}tidy${reset} up intermediate pki engine and ${red}remove${reset} revoked certs"
section --message "$message" --command "$command"
#
# ────────────────────────────────────────────────────────── I ──────────
#   :::::: W I T H   C U R L : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────
#
command=$(cat <<EOF
jq -n \
--arg tidy_revoked_certs "true" \
--arg tidy_cert_store "true" \
'{"tidy_revoked_certs": \$tidy_revoked_certs,"tidy_cert_store": \$tidy_cert_store}' | \
curl -fSsl \
--header "X-Vault-Token: ${VAULT_TOKEN}" \
--request POST \
--data @- \
"${VAULT_ADDR}/v1/pki_int/tidy"
EOF
)
message="using ${yellow}curl${reset} to tidy up intermediate pki engine"
section --message "$message" --command "$command"

#
# ─── SETTING UP TEST CASES ──────────────────────────────────────────────────────
#

#
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C A S E S   T H A T   M U S T   R E T U R N   W I T H O U T   A N   E R R O R : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#


message="${bold}${green}acceptable${reset} common name / alternative name list"
params_list=()
for i in "${!passing_common_names[@]}"; do
  name=${passing_common_names[$i]}
  params_list+=("--params")
  params_list+=("${i}")
  params_list+=("${name}")
done
section --message "${message}" "${params_list[@]}"

#
# ────────────────────────────────────────────────────────────────── I ──────────
#   :::::: R U N N I N G   T E S T S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────
#


message="${bold}iterating${reset} over ${green}acceptable${reset} common name list and trying to generate certificate. all of these commands should return exit code 0 and the loop should not break"
passing_common_names=($(shuf -e "${passing_common_names[@]}"))
command_list=()
for common_name in ${passing_common_names[@]};do
command_list+=("--command")
command_list+=("vault write pki_int/issue/acme-dot-net common_name=${common_name} > /dev/null || exit 1")
done
section --message "$message" "${command_list[@]}"
message="${bold}iterating${reset} over ${red}failing${reset} common name list and trying to generate certificate. all of these commands should return exit code 1"


#
# ────────────────────────────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: C A S E S   T H A T   M U S T   R E T U R N   A N   E R R O R : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#


message="${red}${bold}unacceptable${reset} sample common name / alternative name list"
params_list=()
for i in "${!failing_common_names[@]}"; do
  name=${failing_common_names[$i]}
  params_list+=("--params")
  params_list+=("${i}")
  params_list+=("${name}")
done
section --message "${message}" "${params_list[@]}"

#
# ────────────────────────────────────────────────────────────────── I ──────────
#   :::::: R U N N I N G   T E S T S : :  :   :    :     :        :          :
# ────────────────────────────────────────────────────────────────────────────
#

failing_common_names=($(shuf -e "${failing_common_names[@]}"))
command_list=()
for common_name in ${failing_common_names[@]};do
command_list+=("--command")
command_list+=("vault write pki_int/issue/acme-dot-net common_name=${common_name} && exit 1 || true")
done
section --message "$message" "${command_list[@]}"
