#!/bin/bash
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

if [[ $0 == /dev/fd/* ]]; then
  mkdir -p /tmp/arch-drive/scripts
  download https://bitbucket.org/sgtpep/arch-drive/get/master.tar.gz | tar -xz -C /tmp/arch-drive/scripts --strip-components=1

  exec bash -$- /tmp/arch-drive/scripts/run.sh
fi

bash -$- "`dirname "${BASH_SOURCE[0]}"`"/menu.sh
