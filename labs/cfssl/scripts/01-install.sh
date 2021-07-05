#!/usr/bin/env bash

#-*-mode:sh;indent-tabs-mode:nil;tab-width:2;coding:utf-8-*-
# vi: tabstop=2 shiftwidth=2 softtabstop=2 expandtab:

set -euxo pipefail ;
REPO="cloudflare/cfssl"
architecture="$(uname -m)"
case "$architecture" in
x86_64 | amd64)
  architecture="amd64"
  ;;
*)
  echo >&2 "[ WARN ] unsopported architecture: $architecture"
  exit 0
  ;;
esac
mkdir -p /tmp/cfssl
pushd /tmp/cfssl
set -x
curl -sL "https://api.github.com/repos/${REPO}/releases/latest" \
| jq -r "\
.assets[]|select(\
.browser_download_url \
| (\
contains(\"${architecture}\") \
and contains(\"linux\") \
and (contains(\"sha256\") | not))).browser_download_url" \
| xargs --no-run-if-empty bash -c '
for url do
  name="$(echo $url | sed -e "'"s=.*/=="'" -e "'"s/_.*$//g"'")";
  echo >&2 "*** Downloading ${name}";
  filepath="/usr/local/bin/${name}" ;
  [ -r "${filepah}" ] && sudo rm "${filepath}" ;
  sudo curl \
  --location \
  --remote-header-name \
  --progress-bar \
  --output "${filepath}" \
  "${url}" ;
done' bash ;

# popd
#| sed 's/_.*$//g' \
