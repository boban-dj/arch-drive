#!/bin/bash
set -eu -o pipefail

download() {
  if which curl &>/dev/null; then
    curl $1
  elif which wget &>/dev/null; then
    wget -O - $1
  else
    echo "You need to have curl or wget installed." >&2
    exit 1
  fi
}

if [[ -p $0 ]]; then
  mkdir -p /tmp/arch-drive/src
  download https://github.com/sgtpep/arch-drive/archive/master.tar.gz | tar -xz -C /tmp/arch-drive/src --strip-components=1

  exec bash -$- /tmp/arch-drive/src/run.sh
fi

bash -$- "`dirname "${BASH_SOURCE[0]}"`"/menu.sh
